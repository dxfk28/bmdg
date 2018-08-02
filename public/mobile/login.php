<?php
    error_reporting(E_ALL || ~E_NOTICE); //显示除去 E_NOTICE 之外的所有错误信息
    session_start();
	$DBHOST="";  
	$DBUSER="";  
	$DBPWD="";  
	$user_name = $_GET['user_name'];   //GET方法方便用于调试  
	$user_pwd = $_GET['user_pwd']; 

	//读取xml文件
    $xml = new DOMDocument();
    $xml->load('setting.xml');
    //数据库用户名
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
    //查询全员
    $sqlLogin = "SELECT hashed_password,salt FROM bitnami_redmine.users where login = '$user_name';";//查询加密后的密码和秘钥
    $sqlUsers = "SELECT firstname,lastname,id FROM bitnami_redmine.users where login = '$user_name';";//查询全员
    //连接数据库 
    $conn=mysqli_connect($DBHOST,$DBUSER,$DBPWD);  
    if(!$conn){
       die("Connection failed: " . mysqli_connect_error());
    }
    //获取加密后的密码和秘钥
    $result_Login = $conn->query($sqlLogin);
    $hashed_password = "";
    $salt="";
    if ($result_Login->num_rows > 0) {
    // 输出查到的数据
    while($row = $result_Login->fetch_assoc()) {
        $hashed_password = $row["hashed_password"];
        $salt = $row["salt"];
        }
    } 
    //获取用户名+工号
    $result_users = $conn->query($sqlUsers);
    $value_users = "";
    $value_user_id = "";
    if ($result_users->num_rows > 0) {
    // 输出查到的数据
    while($row = $result_users->fetch_assoc()) {
        $value_users = $row["firstname"].$row["lastname"];
        $value_user_id =  $row["id"];
        }
    } 
    $_SESSION['user_name'] = $value_users;
    
    //aes/ecb解密
    require_once 'CryptAES.php';
    $aes = new CryptAES();
    $user_pwd = $aes->decrypt($user_pwd);

    //加密的过程
	$resultStr = sha1($user_pwd);
	$code = $salt.$resultStr;
	$resultCode = sha1($code);
	//认证过程  
    if ($hashed_password==$resultCode) {
		$loginFlag = "1";   //登录成功
    }else{
	    $loginFlag = "0";   //登录失败 
	}
	//传递json数据
    $returnArr = array("loginFlag" => $loginFlag,"user" => $value_users,"userId"=> $value_user_id);  
    echo json_encode($returnArr);//输出json格式 
	mysqli_close($conn);  //关闭数据库
?>
