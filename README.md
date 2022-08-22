# Notifications : interface administrative

L'interface d'administration pour Notifications. Forkée de [la version
canadienne](https://github.com/cds-snc/notification-admin), elle-même
descendante de [la version
britannique](https://github.com/alphagov/notifications-admin).


## Présentation

### Fonctionnalitées

- création et gestion de comptes utilisateurs ;
- création et gestion de services ;
- envoi d'emails et SMSs en groupe au travers de fichiers CSV ;
- historique des notifications.


### Contraintes

- Nous n'envoyons pas de lettres pour le moment.
- Nous n'avons pas de suivi des accusés de réception pour le moment.


## Installation

Nous passons par un monorepo pour lancer l'admin de concert avec l'API :

https://github.com/betagouv/notifications

## Traductions (section originale du repo canadien)

- Le texte dans le code est en anglais
- Enveloppez votre texte avec `{{ }}`
- Les traductions sont dans `app/translations/csv/fr.csv`

```
<h1>{{ _('Hello') }}</h1>
```

- Pour des conseils sur les formulaires

Créez une variable

```
 <div class="extra-tracking">
  {% set hint_txt = _('We’ll send you a security code by text message') %}
  {{textbox(form.mobile_number, width='3-4', hint=hint_txt) }}
 </div>
```

Pour les formulaires

```
from flask_babel import _
```

Enveloppez votre texte
```
_("Votre texte ici")
```

Pour JavaScript

```
// ajoutez votre texte au main_template
window.APP_PHRASES = {
  now: "{{ _('Now') }}",
}
```

```
// dans vos fichier JS
let now_txt = window.polyglot.t("now") ;
```

- Extrait

Actuellement, il s'agit d'une étape manuelle. Ajoutez une ligne à `fr.csv` dans `app/translations/csv/` pour chaque nouvelle  de charactère que vous avez enveloppée. Le format est le suivant : `"Texte Anglais", "traduction"`. Assurez-vous que la chaîne enveloppée que vous ajoutez est unique.

- Compiler

```Bash
make babel
```

- Tester

Certaines erreurs de frappe dans le fichier `fr.csv` pourraient ne pas être détectées par `babel` mais entraîneraient des changements incorrects ou du texte manquant en français dans l’application. Pour tester contre ces types d’erreurs de frappe qu’on a vu dans le passé, exécutez :
```bash
make test-translations
```
Cette cible make est toujours exécutée pendant le processus d’intégration continue et échouera si des problèmes sont détectés lorsqu’on pousse le code.

## Utiliser Jinja localement pour tester les changements de modèles

Voir le dépôt [notification-api](https://github.com/cds-snc/notification-api) README pour des instructions détaillées.

Fichiers de modèles utilisés dans ce dépôt : `sms_preview_template.jinja2, email_preview_template.jinja2`

Note : les tests peuvent échouer si `USE_LOCAL_JINJA_TEMPLATES` est réglé sur `True` dans votre `.env`
