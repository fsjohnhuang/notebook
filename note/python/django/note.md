项目结构 
  View
  Url
  Model


## url view mapping
urls.py
```
from django.conf.urls import patterns, url, include
from views import users

urlpatterns = patterns('',
  url(r'^users/$', users),
  url(r'^groups/', include('groups.urls')),
)
```
groups/urls.py
```
from django.conf.urls import patterns, url
from views import 

urlpatterns = patterns('',
```
