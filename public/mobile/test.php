<?php
    /**/
    $tmparr[] = array('ClsID'=>'01','ClsName'=>'饮料类');  // [drink] 
    array_push($tmparr[0],array('ItemID'=>'0000','ItemName'=>'碳酸饮料','ItemRate'=>'100%'));  //[sodas]
    array_push($tmparr[0],array('ItemID'=>'0001','ItemName'=>'果汁饮料','ItemRate'=>'100%'));  //[juice]
  
    $tmparr[] = array('ClsID'=>'02','ClsName'=>'食品类');  //[food]
    $tmp[]=array('ItemID'=>'0101','ItemName'=>'生鲜','ItemRate'=>'3%');  //[fresh]
    $tmp[]=array('ItemID'=>'0102','ItemName'=>'熟食','ItemRate'=>'3%');  //[cooked]
    array_push($tmparr[1],$tmp);
      
    $json_str=json_encode($tmparr);
    //print_r($tmparr);
    echo $json_str;
?>
