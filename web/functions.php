<?php

Vesta::add_header_menu('Web Apps', '/plugin/web-apps/');

if (Vesta::is_plugin_page('web-apps')) {
    Vesta::add_css('/plugin/web-apps/style.css');
    // Vesta::add_js('/plugin/web-apps/script.js');
}
