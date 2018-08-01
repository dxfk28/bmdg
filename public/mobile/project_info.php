<?php
error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
    $xml = new DOMDocument();
    $user_id = $_GET['project_id']; 
    $xml->load('setting.xml');

    //redmine api 地址
    foreach($xml->getElementsByTagName('redmineApi') as $list){
    $redmineApi = $list->firstChild->nodeValue;
    }
   
	require_once 'redmineapi/lib/autoload.php';
	$client = new Redmine\Client($redmineApi);
    //  $return = $client->project->listing();
    //  $return = $client->issue_priority->all();
    //$return = $client->membership->all('5');
    $client = new Redmine\Client($redmineApi, '10073', '12345678');
    $return = $client->custom_fields->listing(false,
        ['id' => 1, 'name' => '供应商编码']
    );
    echo json_encode($return);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>