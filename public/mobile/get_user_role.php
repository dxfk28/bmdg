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
    $query_role_id = "select role_id from bitnami_redmine.member_roles,bitnami_redmine.members where bitnami_redmine.member_roles.member_id = bitnami_redmine.members.id and user_id = '$userId' and project_id = '$projectId'";
    
    //取得数据库连接
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
	$result_role_id = $conn->query($query_role_id);
    if ($result_role_id->num_rows > 0) {
        // 输出每行数据
            while($row = $result_role_id->fetch_assoc()) {
                $show_role_id = $row["role_id"];
            }
        } 
       
    $return_json = array("roleId" => $show_role_id);  
    echo json_encode($return_json);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>