# Небольшой Flask-сервер для проксирования youtube-видео

Для некоторых сайтов блокировка youtube будет большой головной болью из-за огромного количества эмбедов видео на страницах. Этот небольшой сервер поможет ее немного облегчить. Вам понадобится:

- купить зарубежный VPS (за крипту, например)
- направить на него FQDN
- установить на него этот сервер (если запустить [вот этот](https://github.com/kirovreporting/ytp/blob/master/uWSGISetup.sh) скрипт из-под рута на минимальном Debian 10, то он сделает всё за вас)
- расположить его за уже имеющимся в инфре реверс-прокси, или поднять на том же самом сервере свой. (если вы запустили скрипт из предыдущего пункта, то всё уже готово)
- заменить в эмбедах на вашем сайте все ссылки вида "https://www.youtube.com/embed/%videoid%" на "https://yourYoutubeProxyDomainName/%videoid%"
- ???
- PROFIT

Если вы попробуете перейти на сайт, не указав ID для видео, то будете успешно зарикроллены. Вас предупредили.

////////////////////////

Idk what are you looking here for, but that's a little Flask server to pass Youtube restrictions in Russia. While running on foreign VPS, it embeds Youtube so you can embed it on your site. Kinda double-embed, heh. So if this is what you want, you should:

- buy VPS
- get an FQDN for it
- install this server on it (or run [this script](https://github.com/kirovreporting/ytp/blob/master/uWSGISetup.sh) as root on minimal Debian 10 installation)
- place it behind reverse-proxy (script from previous point do this as well)
- change your youtube embed urls from "https://www.youtube.com/embed/%videoid%" to "https://yourYoutubeProxyDomainName/%videoid%"
- ???
- PROFIT

If you try to go to the site without providing a video ID, you will be successfully rickrolled. Y'all been warned.