# README

* Отображение списка открытых курсов в Teachbase.

* Список курсов быть с постраничной навигацией.

* Авторизация
Приложение позволяет работать с любым аккаунтом Teachbase,
для этого необходимо в процессе авторизации передать API key.
(Не совсем уверен, что сделал точно то, что требовалось,
возможно это стоит обсудить)

* Если запрос в API Teachbase не был успешным, то показываем на странице последнюю успешно загруженную копию списка (первой страницы, без возможности переключения по страницам) и сообщение "В данный момент Teachbase недоступен. Загружена копия от ...";

* отслеживать долгий простой сервера Teachbase и не делать лишние запросы к API, если Teachbase лежит, а сразу показывать копию + сообщение о том, что "Teachbase лежит уже X часов";
