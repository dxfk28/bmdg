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

    //取得中文名称
    $query_chinese_name = "select value from bitnami_redmine.custom_values where custom_field_id = '13' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得英文名称
    $query_english_name = "select value from bitnami_redmine.custom_values where custom_field_id = '12' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得资产号码
    $query_assest_num = "select value from bitnami_redmine.custom_values where custom_field_id = '8' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得资产类别
    $query_assest_type = "select value from bitnami_redmine.custom_values where custom_field_id = '426' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得使用年限
    $query_assest_year = "select value from bitnami_redmine.custom_values where custom_field_id = '16' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得取得价值
    $query_obtain_value = "select value from bitnami_redmine.custom_values where custom_field_id = '17' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得现存位置
    $query_now_position = "select value from bitnami_redmine.custom_values where custom_field_id = '20' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得是否闲置
    $query_leave_unused = "select value from bitnami_redmine.custom_values where custom_field_id = '438' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    //取得check
    $query_check = "select value from bitnami_redmine.custom_values where custom_field_id = '447' and customized_id = (select customized_id from bitnami_redmine.custom_values where value like '%$managementNum')";
    
    //取得数据库连接
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  

    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
	$result_chinese_name = $conn->query($query_chinese_name);
	$result_english_name = $conn->query($query_english_name);
	$result_assest_num = $conn->query($query_assest_num);
	$result_assest_type = $conn->query($query_assest_type);
	$result_assest_year = $conn->query($query_assest_year);
	$result_obtain_value = $conn->query($query_obtain_value);
	$result_now_position = $conn->query($query_now_position);
	$result_leave_unused = $conn->query($query_leave_unused);
	$result_check = $conn->query($query_check);
	
    if ($result_chinese_name->num_rows > 0) {
        // 输出每行数据
            while($row = $result_chinese_name->fetch_assoc()) {
                $show_chinese_name = $row["value"];
            }
        } 
        if ($result_english_name->num_rows > 0) {
        // 输出每行数据
            while($row = $result_english_name->fetch_assoc()) {
                $show_english_name = $row["value"];
        }
    } 
    if ($result_assest_num->num_rows > 0) {
        // 输出每行数据
        while($row = $result_assest_num->fetch_assoc()) {
            $show_assest_num = $row["value"];
        }
    } 
    if ($result_assest_type->num_rows > 0) {
        // 输出每行数据
        while($row = $result_assest_type->fetch_assoc()) {
            $show_assest_type = $row["value"];
        }
    } 
    if ($result_assest_year->num_rows > 0) {
        // 输出每行数据
        while($row = $result_assest_year->fetch_assoc()) {
            $show_assest_year = $row["value"];
        }
    } 
    if ($result_obtain_value->num_rows > 0) {
        // 输出每行数据
        while($row = $result_obtain_value->fetch_assoc()) {
            $show_obtain_value = $row["value"];
        }
    } 
    if ($result_now_position->num_rows > 0) {
        // 输出每行数据
        while($row = $result_now_position->fetch_assoc()) {
            $show_now_position = $row["value"];
        }
    } 
    if ($result_leave_unused->num_rows > 0) {
        // 输出每行数据
        while($row = $result_leave_unused->fetch_assoc()) {
            $show_leave_unused = $row["value"];
        }
    }
    if ($result_check->num_rows > 0) {
        // 输出每行数据
        while($row = $result_check->fetch_assoc()) {
            $show_check = $row["value"];
        }
    } 
    $return_json = array("chineseName" => $show_chinese_name,"englishName" => $show_english_name,"assestNum" => $show_assest_num,"assestType" => $show_assest_type,"assestYear" => $show_assest_year,"obtainValue" => $show_obtain_value,"nowPosition" => $show_now_position,"leaveUnused" => $show_leave_unused,"check" => $show_check);  
    echo json_encode($return_json);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>