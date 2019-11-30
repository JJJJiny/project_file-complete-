<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>file List</title>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.0/css/bootstrap.min.css">

<script
	src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js"></script>
<script
	src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.0/js/bootstrap.min.js"></script>
<style>
#uploadDiv {
	text-align: right;
}

a {
	text-decoration: none;
	color: black;
}

a:hover {
	color: gray;
}
</style>
</head>
<body>
	<div id="uploadDiv">
		<button id="uploadBtn">업로드</button>
	</div>
	<div id="deleteDiv">
		<button id="deleteBtn">삭제</button>
	</div>
	<table class="table">
		<thead>
			<tr>
				<th scope="col">#</th>
				<th scope="col"><input type=checkbox id="allChk" onclick="allChk(this)"></th>
				<th scope="col">FileName</th>
				<th scope="col">Write_Date</th>
				<th scope="col">Writer</th>
				<th scope="col">Download Count</th>
			</tr>
		</thead>
		<tbody>
			<c:choose>
				<c:when test="${list.size() == 0}">
				<tr><td colspan=6 style="text-align:center">업로드된 파일이 없습니다.</td></tr>
				</c:when>
				<c:otherwise>
					<c:forEach items="${list}" var="file">
						<tr>
							<th scope="row" name="f_seq">${file.f_seq}</th>
							<td><input type=checkbox name="RowCheck" value="${file.f_seq}"></td>
							<td><a id='${file.f_seq}' href="${pageContext.request.contextPath}/download.file?fileName=${file.file_name}&oriName=${file.original_file_name}&f_seq=${file.f_seq}">
							${file.original_file_name}<br></a></td> 
							<td>${file.formedDate}</td>
							<td>${file.f_writer}</td>
							<td  class="cnt_${file.f_seq}">${file.f_downloadCnt}</td>
						</tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>
		
		</tbody>
	</table>

</body>
<script>
	$("a").on("click", function() {
		var id = $(this).attr("id");
		console.log(id);
		$.ajax({
			url : "downloadCount.file",
						type : "post",
						data : {
							f_seq : id
							}, 
						dataType : "json"
					}).done(function(resp){
						console.log(resp);
						var downCnt = resp;
						
                   console.log(resp);
                      //	$("#f_downloadCnt").html(resp);
                       $(".cnt_" + resp.f_seq).html(resp.dCnt);
                    }).fail(function(a,b,c){
						console.log(a);
						console.log(b);
						console.log(c);
					});
	})
	//업로드하러가기
	$("#uploadBtn").on("click",function(){
		$(location).attr("href","${pageContext.request.contextPath}/file/fileForm_6.jsp");
		//location.href="${pageContext.request.contextPath}/file/fileFrom_5.jsp";
			})
			
	//체크박스로 삭제하기
	//$("input:checkbox[name=RowCheck]:checked").each(function(){
    //yourArray.push($(this).val());
    //});
	
			//allCheck하기
			  function allChk(obj){
		      var chkObj = document.getElementsByName("RowCheck");
		      var rowCnt = chkObj.length - 1;
		      var check = obj.checked;
		      if (check) {﻿
		          for (var i=0; i<=rowCnt; i++){
		           if(chkObj[i].type == "checkbox")
		               chkObj[i].checked = true;
		          }
		      } else {
		          for (var i=0; i<=rowCnt; i++) {
		           if(chkObj[i].type == "checkbox"){
		               chkObj[i].checked = false;
		           }
		          }
		      }
		  } 
			﻿ 
﻿ ﻿ 
////////////////
$("#deleteBtn").on("click",function(){
   
     // var nmeCardSeq =0;
      var checkArray = []; 
       
      $("input[name=RowCheck]:checked").each(function(i){   //jQuery로 for문 돌면서 check 된값 배열에 담는다
          checkArray.push($(this).val());
            });
   //   var data = {'checkArrays':checkArray};
      // console.log(data);
//    <c:forEach var="cardselect" items="${cardselect}" varStatus="status">
//        nmeCardSeq= "#"+"${cardselect.nmeCardSeq}";
//        if($(nmeCardSeq).is(":checked")){
//            checkArray.push("${cardselect.nmeCardSeq}");            
//        }
//    </c:forEach>
   
      if(checkArray.length == 0){
          alert("삭제할 파일을 선택하세요.")
      }
      else{
          if (confirm("삭제하시겠습니까?") == true){    //확인
          	console.log(checkArray);
          	console.log(1);
              $.ajax({
              type : 'POST',
              url : 'delete.file',
              dataType : 'json',
              data : {                       
            	  checkArray : JSON.stringify(checkArray)
                  },
                  success: function pageReload(resp){
                  	  console.log("됐어?");
                  	  console.log(resp);
                  	var s = 1;
                  	  for(var i=0; i<resp.length; i++){
                  		  //console.log(resp)
                  		  //console.log(resp.count[i])
                  		  if(resp.count[i] == 'success'){
                  			  s=s*1;
                  		  }else if(resp.count[i] == 'fail'){
                  			  s=s*0
                  		  }
                  	  }
                  	  if(s==1){
                     	location.href="${pageContext.request.contextPath}/list.file"
                  	  }else{
                  		 alert("삭제에 실패하셨습니다.")
                  	  }
                  	  
                  }
              });
              checkArray= new Array();
              //nmeCardSeq=0;
          }
          else{   //취소    
               console.log("안돼");
              location.reload(true);
          }
      }
      
})

</script>
</html>