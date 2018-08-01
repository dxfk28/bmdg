<?php
error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
$xml = new DOMDocument();
    $projectId = $_GET['project_id']; 
    $tracker_id = $_GET['tracker_id']; 
    $project_id = $_GET['project_id']; 
    $subject = $_GET['subject']; 
    $status_id = $_GET['status_id']; 
    $assigned_to_id = $_GET['assigned_to_id']; 
    $priority_id = $_GET['priority_id']; 
    $author_id = $_GET['author_id']; 
    // $tracker_id = '24'; 
    // $project_id = '5'; 
    // $subject = 'shangqinbinceshizhuanyong'; 
    // $status_id = '1'; 
    // $assigned_to_id = '11'; 
    // $author_id = '10';
    // $priority_id = '2';
    $lock_version = '0';
    $done_ratio = '0';
    $is_private = '0';
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

    //保存问题
    $insert_issue = "insert into bitnami_redmine.issues(tracker_id,project_id,subject,status_id,assigned_to_id,priority_id,author_id,lock_version,done_ratio,is_private)values('$tracker_id','$project_id','$subject','$status_id','$assigned_to_id','$priority_id','$author_id','$lock_version','$done_ratio','$is_private');";
    
    //取得数据库连接
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
	$result_insert = $conn->query($insert_issue);
       
    $return_json = array("result" => $result_insert);  
    echo json_encode($return_json);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>