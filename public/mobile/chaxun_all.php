<?php
error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
    $xml = new DOMDocument();
    $managementNum = $_GET['managementNum']; 
    $xml->load('setting.xml');
    ////数据库用户名
    foreach($xml->getElementsByTagName('DBUSER') as $list){
    $DBUSER = $list->firstChild->nodeValue;
    } 
    //数据库密码
    foreach($xml->getElementsByTagName('DBPWD') as $list){
    $DBPWD = $list->firstChild->nodeValue;
    }
    //数据库地址
    foreach($xml->getElementsByTagName('DBHOST') as $list){
    $DBHOST = $list->firstChild->nodeValue;
    }
    //redmine api 地址
    foreach($xml->getElementsByTagName('redmineApi') as $list){
    $redmineApi = $list->firstChild->nodeValue;
    }
   
    //取得数据库连接
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
	require_once 'redmineapi/lib/autoload.php';
	$client = new Redmine\Client($redmineApi, 'test2', '12345678');
	$return = $client->issue->all(['author_id' => '10']);
    $return_json = array("chineseName" => $show_chinese_name,"englishName" => $show_english_name,"assestNum" => $show_assest_num,"assestType" => $show_assest_type,"assestYear" => $show_assest_year,"obtainValue" => $show_obtain_value,"nowPosition" => $show_now_position,"leaveUnused" => $show_leave_unused,"check" => $show_check);  
    echo json_encode($return);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>