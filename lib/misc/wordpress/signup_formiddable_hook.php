// admin_hooks.php

add_action('frm_after_create_entry', 'signup_stronghold', 30, 2);
function signup_stronghold($entry_id, $form_id){
 if($form_id == 7){
    $args = array();
    if(isset($_POST['item_meta'][89])) 
      $args['email'] = $_POST['item_meta'][89];
    if(isset($_POST['item_meta'][90]))
      $args['organization_name'] = $_POST['item_meta'][90]; 
    $result = wp_remote_post('https://my.datacentred.io/signup', array('body' => $args));
 }
}