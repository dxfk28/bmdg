<?php
error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
$xml = new DOMDocument();
    $projectId = $_GET['project_id']; 
    $userId = $_GET['user_id']; 
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

    //取得用户角色
    $query_value = "select possible_values from bitnami_redmine.custom_fields where name='修理部门_修理担当'";
    
    //取得数据库连接
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
	$quresult_value = $conn->query($query_value);
    if ($quresult_value->num_rows > 0) {
        // 输出每行数据
            while($row = $quresult_value->fetch_assoc()) {
                $show_value = $row["possible_values"];
            }
        } 
       
    $return_json = array("value" => $show_value);  
    echo json_encode($return_json);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>