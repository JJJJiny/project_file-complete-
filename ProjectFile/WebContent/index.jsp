<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
</head>
<body>
<button id="toFileMenu">File Menu</button>
<script>
$("#toFileMenu").on("click",function(){
	$(location).attr("href","${pageContext.request.contextPath}/list.file");
})
</script>
</body>
</html>


