import pytest

from functools import partial
from unittest.mock import Mock
from notifications_utils.template import LetterPreviewTemplate

from app.template_previews import TemplatePreview, get_page_count_for_letter


@pytest.mark.parametrize('partial_call, expected_page_argument', [
    (partial(TemplatePreview.from_utils_template), None),
    (partial(TemplatePreview.from_utils_template, page=99), 99),
])
def test_from_utils_template_calls_through(
    mocker,
    mock_get_service_letter_template,
    partial_call,
    expected_page_argument,
):
    mock_from_db = mocker.patch('app.template_previews.TemplatePreview.from_database_object')
    template = LetterPreviewTemplate(mock_get_service_letter_template(None, None)['data'])

    ret = partial_call(template, 'foo')

    assert ret == mock_from_db.return_value
    mock_from_db.assert_called_once_with(template._template, 'foo', template.values, page=expected_page_argument)


@pytest.mark.parametrize('partial_call, expected_url', [
    (
        partial(TemplatePreview.from_database_object, filetype='bar'),
        'http://localhost:6013/preview.bar',
    ),
    (
        partial(TemplatePreview.from_database_object, filetype='baz'),
        'http://localhost:6013/preview.baz',
    ),
    (
        partial(TemplatePreview.from_database_object, filetype='bar', page=99),
        'http://localhost:6013/preview.bar?page=99',
    ),
])
def test_from_database_object_makes_request(
    mocker,
    client,
    partial_call,
    expected_url,
):
    resp = Mock(content='a', status_code='b', headers={'c': 'd'})
    request_mock = mocker.patch('app.template_previews.requests.post', return_value=resp)
    mocker.patch('app.template_previews.current_service', __getitem__=Mock(return_value='123'))

    ret = partial_call(template='foo')

    assert ret[0] == 'a'
    assert ret[1] == 'b'
    assert list(ret[2]) == [('c', 'd')]

    data = {
        'letter_contact_block': '123',
        'template': 'foo',
        'values': None,
        'dvla_org_id': '123',
    }
    headers = {'Authorization': 'Token my-secret-key'}

    request_mock.assert_called_once_with(expected_url, json=data, headers=headers)


@pytest.mark.parametrize('template_type', [
    'email', 'sms'
])
def test_page_count_returns_none_for_non_letter_templates(template_type):
    assert get_page_count_for_letter({'template_type': template_type}) is None


@pytest.mark.parametrize('partial_call, expected_template_preview_args', [
    (
        partial(get_page_count_for_letter),
        ({'template_type': 'letter'}, None)
    ),
    (
        partial(get_page_count_for_letter, values={'foo': 'bar'}),
        ({'template_type': 'letter'}, {'foo': 'bar'})
    ),
])
def test_page_count_unpacks_from_json_response(
    mocker,
    partial_call,
    expected_template_preview_args,
):
    mock_template_preview = mocker.patch('app.template_previews.TemplatePreview.from_database_object')
    mock_template_preview.return_value = (b'{"count": 99}', 200, {})

    assert partial_call({'template_type': 'letter'}) == 99
    mock_template_preview.assert_called_once_with(*expected_template_preview_args, filetype='json')
