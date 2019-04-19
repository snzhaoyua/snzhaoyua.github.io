#!/bin/bash

  #修改apache服务器端口号
#  sed -i "s/Listen 80/Listen 8090/g" /etc/apache2/ports.conf
  sed -i 's/Require local/Require all granted/g' etc/extra/httpd-xampp.conf
  #修改phpmyadmin相关配置
  sed -i "s/\$cfg\['AllowArbitraryServer'\] = false/\$cfg\['AllowArbitraryServer'\] = true/g" /opt/lampp/phpmyadmin/libraries/config.default.php
  #此处留空，登录界面可以输入 x.x.x.x:13307 登录
  sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/\$cfg\['Servers'\]\[\$i\]\['host'\] = '${myadmin_ip}:${mysql_port}';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg\['blowfish_secret'\] = '1de007eb-74c8-40ff-99ec-67ddbc8ff16c-9e5591be-a5e5-4019-a471-96285ea29bce';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['pmadb'\] = 'phpmyadmin';/\$cfg\['Servers'\]\[\$i\]\['pmadb'\] = 'phpmyadmin';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['bookmarktable'\] = 'pma__bookmark';/\$cfg\['Servers'\]\[\$i\]\['bookmarktable'\] = 'pma__bookmark';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['relation'\] = 'pma__relation';/\$cfg\['Servers'\]\[\$i\]\['relation'\] = 'pma__relation';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['table_info'\] = 'pma__table_info';/\$cfg\['Servers'\]\[\$i\]\['table_info'\] = 'pma__table_info';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['table_coords'\] = 'pma__table_coords';/\$cfg\['Servers'\]\[\$i\]\['table_coords'\] = 'pma__table_coords';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['pdf_pages'\] = 'pma__pdf_pages';/\$cfg\['Servers'\]\[\$i\]\['pdf_pages'\] = 'pma__pdf_pages';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['column_info'\] = 'pma__column_info';/\$cfg\['Servers'\]\[\$i\]\['column_info'\] = 'pma__column_info';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['history'\] = 'pma__history';/\$cfg\['Servers'\]\[\$i\]\['history'\] = 'pma__history';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['table_uiprefs'\] = 'pma__table_uiprefs';/\$cfg\['Servers'\]\[\$i\]\['table_uiprefs'\] = 'pma__table_uiprefs';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['tracking'\] = 'pma__tracking';/\$cfg\['Servers'\]\[\$i\]\['tracking'\] = 'pma__tracking';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['userconfig'\] = 'pma__userconfig';/\$cfg\['Servers'\]\[\$i\]\['userconfig'\] = 'pma__userconfig';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['recent'\] = 'pma__recent';/\$cfg\['Servers'\]\[\$i\]\['recent'\] = 'pma__recent';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['favorite'\] = 'pma__favorite';/\$cfg\['Servers'\]\[\$i\]\['favorite'\] = 'pma__favorite';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['users'\] = 'pma__users';/\$cfg\['Servers'\]\[\$i\]\['users'\] = 'pma__users';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['usergroups'\] = 'pma__usergroups';/\$cfg\['Servers'\]\[\$i\]\['usergroups'\] = 'pma__usergroups';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['navigationhiding'\] = 'pma__navigationhiding';/\$cfg\['Servers'\]\[\$i\]\['navigationhiding'\] = 'pma__navigationhiding';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['savedsearches'\] = 'pma__savedsearches';/\$cfg\['Servers'\]\[\$i\]\['savedsearches'\] = 'pma__savedsearches';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['central_columns'\] = 'pma__central_columns';/\$cfg\['Servers'\]\[\$i\]\['central_columns'\] = 'pma__central_columns';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['designer_settings'\] = 'pma__designer_settings';/\$cfg\['Servers'\]\[\$i\]\['designer_settings'\] = 'pma__designer_settings';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
  sed -i "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['export_templates'\] = 'pma__export_templates';/\$cfg\['Servers'\]\[\$i\]\['export_templates'\] = 'pma__export_templates';/g" /opt/lampp/phpmyadmin/config.sample.inc.php
#  rm /opt/lampp/phpmyadmin/config.inc.php
  mv /opt/lampp/phpmyadmin/config.sample.inc.php /opt/lampp/phpmyadmin/config.inc.php
