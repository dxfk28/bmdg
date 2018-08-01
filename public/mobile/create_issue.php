<?php
error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
    $xml = new DOMDocument();
    // $tracker_id = $_GET['tracker_id']; 
    // $project_id = $_GET['project_id']; 
    // $subject = $_GET['subject']; 
    // $status_id = $_GET['status_id']; 
    // $assigned_to_id = $_GET['assigned_to_id']; 
    // $priority_id = $_GET['priority_id']; 
    // $author_id = $_GET['author_id']; 
    // $user_name = $_GET['user_name'];   //GET方法方便用于调试  
	// $user_pwd = $_GET['user_pwd']; 
    $tracker_id = '24'; 
    $project_id = '5'; 
    $subject = 'shangqinbinceshizhuanyong'; 
    $status_id = '1'; 
    $assigned_to_id = '11'; 
    $author_id = '10';
    $priority_id = '2';
    $lock_version = '0';
    $done_ratio = '0';
    $is_private = '0';
    $xml->load('setting.xml');

    //redmine api 地址
    foreach($xml->getElementsByTagName('redmineApi') as $list){
    $redmineApi = $list->firstChild->nodeValue;
    }
    
     //aes/ecb解密
     require_once 'CryptAES.php';
     $aes = new CryptAES();
     $user_pwd = $aes->decrypt($user_pwd);

	require_once 'redmineapi/lib/autoload.php';
	$client = new Redmine\Client($redmineApi, 'test1', '12345678');

    $result_insert = $client->api('issue')->create([
        'tracker_id' => $tracker_id,
        'project_id' => $project_id,
        'subject' => $subject,
        'status_id' => $status_id,
        'assigned_to_id' => $assigned_to_id,
        'priority_id' => $priority_id,
        'author_id' => $author_id,
        'lock_version' => $lock_version,
        'done_ratio' => $done_ratio,
        'is_private' => $is_private,
        'custom_fields' => [
            [
            'id' => '108',
            'value' => '2018-07-04'
            ],
            [
                'id' => '109',
                'value' => '2018-07-04'
            ]]
        ]);
    $return_json = array( $result_insert);  
    echo json_encode($return_json);//输出json格式 

?>