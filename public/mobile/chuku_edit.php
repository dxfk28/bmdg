<?php
$xml = new DOMDocument();
$managementNum = $_GET['managementNum'];
$unused = $_GET['unused'];
    
    $xml->load('setting.xml');
    ////���ݿ��û���
    foreach($xml->getElementsByTagName('DBUSER') as $list){
    $DBUSER = $list->firstChild->nodeValue;
    } 
    //���ݿ�����
    foreach($xml->getElementsByTagName('DBPWD') as $list){
    $DBPWD = $list->firstChild->nodeValue;
    }
    //���ݿ��ַ
    foreach($xml->getElementsByTagName('DBHOST') as $list){
    $DBHOST = $list->firstChild->nodeValue;
    }

   //�����Ƿ�����
    $update_leave_unused = "update bitnami_redmine.custom_values set value = '$unused' where custom_field_id = '438' and customized_id = (select customized_id from (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum') as temtable)";
    
    //ȡ�����ݿ�����
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
    $result = $conn->query($update_leave_unused);
	$return_json = array("result" => $result);
	echo json_encode($return_json);//���json��ʽ 
	mysqli_close($conn);  //�ر����ݿ�
?>