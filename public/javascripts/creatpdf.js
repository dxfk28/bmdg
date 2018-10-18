function convert() {
          html2canvas(document.body, {
              onrendered:function(canvas) {
                  var contentWidth = canvas.width;
                  var contentHeight = canvas.height;
                  //一页pdf显示html页面生成的canvas高度;
                  var pageHeight = contentWidth / 595.28 * 841.89;
                  //未生成pdf的html页面高度
                  var leftHeight = contentHeight;
                  //pdf页面偏移
                  var position = 0;
                  //a4纸的尺寸[595.28,841.89]，html页面生成的canvas在pdf中图片的宽高
                  var imgWidth = 555.28;
                  var imgHeight = 555.28/contentWidth * contentHeight;
                  //将HTML5 Canvas内容保存为图片,格式为png,精度范围为0-1
                  var pageData = canvas.toDataURL('image/png', 1.0);

                  var pdf = new jsPDF('', 'pt', 'a4');
                  //有两个高度需要区分，一个是html页面的实际高度，和生成pdf的页面高度(841.89)
                  //当内容未超过pdf一页显示的范围，无需分页
                  if (leftHeight < pageHeight) {
                      pdf.addImage(pageData, 'PNG', 20, 0, imgWidth, imgHeight );
                  } else {
                      while(leftHeight > 0) {
                          pdf.addImage(pageData, 'PNG', 20, position, imgWidth, imgHeight)
                          leftHeight -= pageHeight;
                          position -= 841.89;
                          //避免添加空白页
                          if(leftHeight > 0) {
                              pdf.addPage();
                          }
                      }
                  }
                  pdf.save('pdf_'+Date.now()+'.pdf');
              }
          })
      }



    function addTable(){
var tab=document.getElementById("myTable"); //获得表格
var colsNum=tab.rows.item(0).cells.length; //表格的列数
//表格当前的行数 
var num=document.getElementById("myTable").rows.length;
var rownum=num;
tab.insertRow(rownum);
for(var i=0;i<5; i++)
{
tab.rows[rownum].insertCell(i);//插入列
if(i==0){
tab.rows[rownum].cells[i].innerHTML=rownum;
}else if(i==1){
tab.rows[rownum].cells[i].innerHTML='<input type="text" name="" class="input_text_style1">';
}else if(i==2){
tab.rows[rownum].cells[i].innerHTML='<input name="quantity" type="text" class="input_text_style1"/>';
}else if(i==3){
tab.rows[rownum].cells[i].innerHTML='<input type="number" min="0" step="1" name="" class="input_text_style1"/>';  
}else{
tab.rows[rownum].cells[i].innerHTML='<input name="weight" type="text" class="input_text_style1"/>'; 
}
}
//tab.rows[rownum].insertCell(i);
}




  function addTable1(){
  var tab=document.getElementById("myTable"); //获得表格
  var colsNum=tab.rows.item(0).cells.length; //表格的列数
  //表格当前的行数 
  var num=document.getElementById("myTable").rows.length;
  var rownum=num;
  tab.insertRow(rownum);
  for(var i=0;i<7; i++)
{
tab.rows[rownum].insertCell(i);//插入列
if(i==0){
tab.rows[rownum].cells[i].innerHTML=rownum-1;
}else if(i==1){
tab.rows[rownum].cells[i].innerHTML='<input name="productNumber" type="text" class="input_text_style1"/>';
}else if(i==2){
tab.rows[rownum].cells[i].innerHTML='<input name="quantity" type="text" class="input_text_style1"/>';
}else if(i==3){
tab.rows[rownum].cells[i].innerHTML='<input name="weight" type="number" class="input_text_style1"/>';
}else if (i==4) {
tab.rows[rownum].cells[i].innerHTML='<input name="weight" type="number" class="input_text_style1"/>'; 
}else if (i==5) {
tab.rows[rownum].cells[i].innerHTML='<input name="weight" type="number" class="input_text_style1"/>'; 
}else{
tab.rows[rownum].cells[i].innerHTML='<input name="weight" type="text" class="input_text_style1"/>'; 
}
}
//tab.rows[rownum].insertCell(i);
}