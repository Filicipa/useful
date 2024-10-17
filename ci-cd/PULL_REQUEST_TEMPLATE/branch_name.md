## Description

Please include a summary of the change and which issue is fixed. Please also include relevant motivation and context. List any dependencies that are required for this change.

Fixes # (issue with link to [JIRA](https://cowchain.atlassian.net/))

## Type of change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] This change requires a documentation update

## Checklist:

- [ ] I have performed a self-review of my own code
- [ ] My changes generate no new warnings
- [ ] Deleted unnecessary log
- [ ] Deleted unused code


### Чек-лист перед следующим релизом:
Пробуем изменить настройки GitHub и смотрим заставляет ли он снова решить конфликты, если да, то не решаем их, отменяем всё и переходим к следующим действиям:
- Выкачиваем локально последние изменения из  release  и master веток.
- Переходим на ветку релиз git checkout release
- Делаем мёрж мастера в релиз git merge master или git merge -X theirs master если уверены, что нужны только ченжи с мастера.
- Пушим ветку с релиз мёрж коммитом на GitHub: git push -u origin release
- Заходим на GitHub и добавляем релизный тег