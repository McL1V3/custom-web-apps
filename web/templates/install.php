<?php if (!class_exists('Vesta')) {
    exit;
} ?>

<div class="l-center units vestacp-web-apps">

<form action="index.php" method="post">
    <h1><?= __('Web Apps'); ?></h1>

    <select name="app" class="vst-list" required>
        <option value="" style="display:none" disabled><?= __('Selecciona una App'); ?></option>
        <option value="wordpress">Wordpress</option>
        <option value="wordpress_with_database">Wordpress With Database</option>
        <option value="moodle">Moodle</option>
    </select>
    <br><br>

    <select name="web_domain" class="vst-list" required>
        <option value="" style="display:none" disabled><?= __('Selecciona un dominio'); ?></option>
        <?php
        $users = Vesta::exec('v-list-users', 'json');
        ksort($users);

        foreach ($users as $user_name => $value) {
            $web_domains = Vesta::exec('v-list-web-domains', $user_name, 'json');
            ksort($web_domains);

            foreach ($web_domains as $web_domain => $domain_data) {
                if ($user == 'admin' || $user == $user_name) {
                    $display_name = ($_SESSION['user'] == 'admin') ? "$user_name - $web_domain" : "$web_domain";

                    echo "<option value=\"$user_name|$web_domain\">$display_name</option>";
                }
            }
        }
        ?>
    </select>
    <br><br>
    <label ><input id="checkdatabase" style="display:initial;" type="checkbox" class="vst-checkbox" name="database" checked @click="">Crear una base datos</label>
    <br><br>
    <select id="selectdatabase" name="database" class="vst-list" required>
        <option value="" style="display:none" disabled><?= __('Seleciona una base de datos'); ?></option>
        <?php
        $databases = Vesta::exec('v-list-databases', $user, 'json');
        ksort($databases);

        foreach ($databases as $database => $dbv) {
            $db = $dbv;
            if ($db['TYPE'] == 'mysql' && $db['SUSPENDED'] == 'no') {
                echo '<option value="'.$db['DATABASE'].'|'.$db['DBUSER'].'">'.$db['DATABASE'].' - '.$db['DBUSER'].'</option>';
            }
        }
        ?>
    </select>
    <br><br>

    <input type="hidden" name="action" value="install"/>
    <button class="button confirm" type="submit"><?= __('Instalar'); ?></button>
</form>
</div>
<script>
var select = document.getElementById("selectdatabase"); 
var checked=document.getElementById("checkdatabase");
checked.addEventListener("change", function(){ 
   var checked=document.getElementById("checkdatabase");
   if(select){
       if(checked.checked){
            select.style.display = "none";
        }else{
            select.style.display = "initial";
        }
   }
}); 
if(select){
       if(checked.checked){
        select.style.display = "none";
        }else{
            select.style.display = "initial";
        }
   }
   </script>