<?php
error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
    $xml = new DOMDocument();
    $issue_id = $_GET['issue_id'];
    $tracker_id = $_GET['tracker_id']; 
    $project_id = $_GET['project_id']; 
    $subject = $_GET['subject']; 
    $status_id = $_GET['status_id']; 
    $assigned_to_id = $_GET['assigned_to_id']; 
    $priority_id = $_GET['priority_id']; 
    $custom_fields_121 = $_GET['custom_fields_121'];  //修理部门_接收管理番号
    $custom_fields_122 = $_GET['custom_fields_122'];  //修理部门_接收日期
    $custom_fields_123 = $_GET['custom_fields_123'];  //修理部门_修理完日期
    $custom_fields_124 = $_GET['custom_fields_124'];  //修理部门_修理工数
    $custom_fields_119 = $_GET['custom_fields_119'];  //修理部门_不良现象描述
    $custom_fields_126 = $_GET['custom_fields_126'];  //修理部门_修理内容
    $custom_fields_125 = $_GET['custom_fields_125'];  //修理部门_修理担当
    $custom_fields_661 = $_GET['custom_fields_661'];  //修理部门_修理担当
    $user_name = $_GET['user_name'];   //GET方法方便用于调试  
	$user_pwd = $_GET['user_pwd']; 
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
	$client = new Redmine\Client($redmineApi, $user_name, $user_pwd);

    $result_update = $client->api('issue')->update($issue_id,[
        'subject' => $subject,
        'status_id' => $status_id,
        'assigned_to_id' => $assigned_to_id,
        'priority_id' => $priority_id,
        'custom_fields' => [
            [
                'id' => '121',
                'value' => $custom_fields_121
            ],
            [
                'id' => '122',
                'value' => $custom_fields_122
            ],
            [
                'id' => '123',
                'value' => $custom_fields_123
            ],
            [
                'id' => '124',
                'value' => $custom_fields_124
            ],
            [
                'id' => '119',
                'value' => $custom_fields_119
            ],
            [
                'id' => '126',
                'value' => $custom_fields_126
            ],
            [
                'id' => '125',
                'value' => $custom_fields_125
            ],
            [
                'id' => '661',
                'value' => $custom_fields_661
            ]]
        ]);
    $return_json = array("result" => $result_update);  
    echo json_encode($return_json);//输出json格式 
?>