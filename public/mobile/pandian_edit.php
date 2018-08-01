<?php
$xml = new DOMDocument();
$managementNum = $_GET['managementNum']; 
$check = $_GET['check']; 
    
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

   //更新check
    $update_check = "update bitnami_redmine.custom_values set value = '$check' where custom_field_id = '447' and customized_id = (select customized_id from (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum') as temtable)";
    
    //取得数据库连接
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
    $result = $conn->query($update_check);
	$return_json = array("result" => $result);
	echo json_encode($return_json);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>