from django.conf import settings
from django.conf.urls import patterns, include, url
from django.views.generic.base import TemplateView

#Example of how to handle web-down state to redirect user to a down page
if not settings.SITE_DOWN:
    urlpatterns = patterns('',
        url(r'', include('main.urls')),
    )
else:
    urlpatterns = patterns('',
        url(r'', TemplateView.as_view(template_name='main/down.html')),
    )