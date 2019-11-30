<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>FileApi-DragDrop</title>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<meta charset="UTF-8">
<link rel="stylesheet" href="ddf.css">
<script>
	var MAX_TOTAL_SIZE = 10000000; //서버에서 최대로 받을 수 있는 사이즈 
	var totalBytes = 0; //업로드 대상 파일 총 사이즈
	var totalCount = 0; //업로드 대상 파일 총 개수
	var files; //HTML5의 FileAPI가 반환한 파일객체 참조용 변수
	var dragged; //드래그된 객체 참조용 변수
	var progressBar; //<progress> Element 참조용 변수
	var progress; //업로드 진척률 변수
	var formData = new FormData(); //FormData 타입객체(Content-Type => "multipart/form-data")
	
	//(1)가장 먼저 호출되는 함수
	function fnOnLoad() {		
		//쓰레기통 레퍼런스 저장
		var wasteBasket = document.getElementById('wastebasket');		
		//쓰레기통 기능 설정 - ondragover 이벤트 설정
		wasteBasket.ondragover = function(event) {
			if (event.dataTransfer.effectAllowed == "move") {  //move속성을 가진 Element가 전달되면...
				event.target.style.backgroundColor = "red";    //바탕색을 빨간색으로 변경한다.
			}
			event.preventDefault(); 
		}	
		//쓰레기통 기능 설정 - ondragleave 이벤트 설정
		wasteBasket.ondragleave = function(event) {
			event.target.style.backgroundColor = "transparent";  //쓰레기통을 벗어나면 바탕색을 투명하게 바꾼다.
			event.preventDefault();
		}		
		//쓰레기통 기능 설정 - ondrop 이벤트 설정
		wasteBasket.ondrop = function(event) {
			event.target.style.backgroundColor = "transparent"; //쓰레기통에 객체를 떨구면 바탕색을 흰색으로 변경한다.
			if (event.dataTransfer.effectAllowed == "move") {
				//지우려는 객체의 id를 받아온다.
				var sourceId = event.dataTransfer.getData("delFileId");
				//id에 해당하는 객체의 레퍼런스를 얻는다.
				var sourceLi = document.getElementById(sourceId);
				//id에 해당하는 객체의 'filesize' 값을 읽어온다.
				var delFileSize = sourceLi.getAttribute("filesize");
				
				//총 첨부파일 사이즈에서 삭제한 객체의 크기를 뺀다.
				totalBytes = totalBytes - delFileSize; 
				//첨부파일 목록에서 객체를 삭제한다.
				dragged.parentNode.removeChild(dragged); 
				//첨부파일 개수를 하나줄인다.
				totalCount--; 
				
				if( totalCount == 0 ){ //첨부파일 개수가 0개라면...
					//첨부파일 업로드 이미지를 다시 보여준다.
					document.getElementById("intro").style.display = "initial";
					//서버 전송 대상 파일정보들을 초기화
					formData = new FormData();
				}				
				//최종 첨부파일 정보를 'summary'에 저장
				document.getElementById("summary").setAttribute("data-total-count", totalCount);
				document.getElementById("summary").setAttribute("data-total-size", totalBytes);
				fnUpdateSummary();
			}
		}		
		//파일박스 레퍼런스 저장
		var fileBox = document.getElementById('files');			
		//파일박스 화면위로 파일이 옮겨질 때
		fileBox.ondragover = function(event) {
			event.stopPropagation();
			event.preventDefault();
		};
		//파일박스 화면에 파일을 떨굴때
		fileBox.ondrop = function(event) {
			event.stopPropagation();
			event.preventDefault(); //브라우저가 이벤트와 연관된 기본 액션을 하는 것을 불가능하게 막음			
			//파일박스가 비어있는 상태에서 drop하는 첫번째 파일이라면, 이전 결과를 초기화한다.
			if( totalCount == 0 ){
				fnAllClear();
			}
			// 드래그를 통해 전달된 로컬 파일들에 대한 정보를 files변수에 저장 
			files = event.dataTransfer.files; 
		    //드래그를 통해 전달된 파일 개수
			var count = files.length;
			//첨부파일 업로드 이미지를 보이지 않게한다.(이미지가 차지하는 공간도 zero로 만듬)
			document.getElementById("intro").style.display = "none";
			for (var inx = 0; inx < count; inx++) {
				var filename = files[inx].name;
				/**
				 * 파일명에 포함된 모든 공백을 제거한다.
				 * 그래야 인코딩해서 전달한 파일명이 서버에서 디코딩될 때
				 * 공백이 '+'문자로 대체되는 문제를 예방할 수 있다.
				 * (문제 예)'사용자 설문 자료.zip' => '사용자+설문+자료.zip'
				 */
				filename = filename.replace(/\s/gi, ''); 			 
				var filesize = files[inx].size;			
				/*************************************************************
				 * 첨부파일 Validation Check
				 * 1. 전체 파일 사이즈 체크
				 * 2. 첨부파일 확장자 체크(실행파일 업로드 금지)
				 * [주의] JavaScript를 이용한 Validation은 쉽게 변조되므로
				 *        반드시 서버단에서 한번 더 체크해야 한다!
				 *************************************************************/			 
				//1. 첨부되는 개별 파일들의 사이즈를 합해서 업도드 크기 제한에 걸리는지 확인한다.
				totalBytes += Number(filesize);
				if( totalBytes >= MAX_TOTAL_SIZE ){
					alert('업로드 대상 파일의 총 크기는 10MB미만입니다.\n10MB미만으로 올려주세요.');
					fnAllClear(); //첨부파일 정보 초기화
					return; //업로드 크기 제한에 위배되면 즉시 작업을 중단한다.
				}				
				//2. 첨부파일 확장자를 체크하여 실행파일 업로드를 금지한다.
				var ext = filename.split('.').pop(); //파일 확장자만 분리
				ext = ext.toLowerCase(); //확장자를 소문자로 변경
				var bannedExt = 'exe,js,class,jar,war,lnk'; //업로드가 금지된 확장자
				var found = bannedExt.match(ext);
				if( found ){ //found가 null 이면 false, 확장자가 반환되면 true 이다.
					alert('업로드 금지대상 파일이 포함되어 있습니다.\n다시 올려주세요.\n\n[업로드 금지대상 파일] exe, js, class, jar, war');
					fnAllClear(); //첨부파일 정보 초기화
					return; //첨부파일 확장자 체크에 위배되면 즉시 작업을 중단한다.
				} 
				
				//drag-drop된 첨부파일 정보를 보여주기 위해 신규 <li> 태그 생성
				var li = document.createElement("li");
				li.setAttribute("draggable", true); //drag-drop이 가능하도록 'draggable' 속성에 true 설정 
				li.setAttribute("filesize", filesize); //'filesize' 속성을 추가하고 파일크기 설정
				li.setAttribute("id", filename); //'id' 속성을 추가하고 파일명 설정
				// 삭제옵션 추가 및 삭제시 총 첨부파일 사이즈 재계산을 위해 파일 크기 정보도 추가
				li.ondragstart = function(event) {
					//쓰레기통(id='wastebasket')에 떨굴 때 삭제하능하도록 'move' 속성 설정
					event.dataTransfer.effectAllowed = "move";
					event.dataTransfer.setData('delFileId', this.id) //this.id => 파일명 전달
					dragged = event.target; //삭제할 객체의 레퍼런스
				}				
				//첨부된 파일의 확장자에 따라 적절한 파일 아이콘을 보여주기 위해 <div> 태그 생성 및 class 속성 설정
				var div = document.createElement("div"); 
				div.classList.add("icon");
				div.classList.add(ext);
				li.appendChild(div); //신규 <div> 태그를 <li> 태그에 추가                 
				//첨부된 파일의 파일명을 보여주기 위한 <p> 태그 생성 및 파일명 설정
				var p1 = document.createElement("p");
				p1.classList.add("file-info");
				p1.textContent = filename;
				//첨부된 파일의 파일사이즈를 보여주기 위한 <p> 태그 생성 및 파일사이즈 설정
				var p2 = document.createElement("p");
				p2.classList.add("file-info");
				p2.textContent = "(" + fnGetSizeString(filesize) + ")";			
				//<li> 태그에 위에서 생성한 <p> 태그들을 추가	
				li.appendChild(p1);
				li.appendChild(p2);
				
				//파일박스에 최종 <li> 태그를 추가
				document.getElementById("fileList").appendChild(li);
				
				/*****************************************************************************************
				 * 업로드 버튼 클릭 시 서버로 파일들을 전송하기 위해 formData에 files 변수 추가
				 * [주의] 첨부 파일명이 한글인 경우 전송중 한글깨짐 문제가 발생하므로 파일명은 별도로  
				 *        fileNames 변수에 인코딩해서 전송한다.   
				 *****************************************************************************************/
				formData.append('file', files[inx]);
				formData.append('fileNames', encodeURIComponent(filename)); //encoding하지 않으면 한글명이 깨진다.
				
			}

			totalCount += count; //전송대상 총 파일 개수 갱신
			document.getElementById("summary").setAttribute("data-total-count", totalCount);
			document.getElementById("summary").setAttribute("data-total-size", totalBytes);
			fnUpdateSummary(); //전체 첨부파일 정보(파일개수, 총 사이즈)를 'id=summary' Element를 통해 보여준다.
		};
	}

	// 바이트 값(size)을 MB, KB, B 단위의 문자열로 변환
	function fnGetSizeString(size) {
		if (size >= 1000000) {
			return Math.floor(size / 1000000) + "MB";
		}

		if (size >= 1000) {
			return Math.floor(size / 1000) + "KB";
		}

		return size + "B";
	}

	//Drag-drop된 모든 파일정보들을 초기화
	function fnClearFiles() {
		
		//전역변수를 초기화 한다.
		totalCount = 0;
		totalBytes = 0;
		
		//서버 전용용 파일들의 정보를 저장하고 있는 FormData 초기화
		formData = new FormData();
		
		//첨부파일박스에 추가된 첨부파일 관련 태그들을 모두 제거한다. 
		var lis = document.querySelectorAll("#fileList li");
		for (var inx = 0; inx < lis.length; inx++) {
			if (lis[inx].id != "intro") {
				lis[inx].parentNode.removeChild(lis[inx]);
			}
		}
		
		//최종 첨부파일 정보(파일수, 총크기)를 갱신한다.
		document.getElementById("summary").setAttribute("data-total-count", totalCount);
		document.getElementById("summary").setAttribute("data-total-size", totalBytes);
		fnUpdateSummary();
		
		//첨부파일 업로드 이미지를 다시 보여준다.
		document.getElementById("intro").style.display = "initial";
	}
	
	//업로드 결과를 초기화 한다.
	function fnResultInitialize(){
		//업로드결과화면(id='resultList' 태그) 초기화
		document.getElementById("resultList").innerHTML = "<center>업로드 결과</center>";
		//업로드 진행상태바(id='progressBar') 및 진척률(id='progress') 정보 초기화
		progressBar = document.getElementById("progressBar");
		progressBar.value = 0;
		progress = document.getElementById("progress");
		progress.innerText = ' 0%';
	}
	
	//Drag-drop된 모든 파일정보들을 초기화 + 업로드 결과를 초기화
	function fnAllClear(){
		fnClearFiles();
		fnResultInitialize();
	}
	
	//전체 첨부파일 정보(파일개수, 총 사이즈)를 'id=summary' Element를 통해 보여준다.
	function fnUpdateSummary() {
		var size = document.getElementById("summary").getAttribute("data-total-size");
		var count = document.getElementById("summary").getAttribute("data-total-count");
		document.getElementById("summary").innerText = count + "개 파일 [총 " + size + " byte]";
	}
	
	//파일박스에 존재하는 파일들을 서버로 업로드
	function fnUpload(files) {
		
		//Ajax로 호출하고자 하는 URL
		//var callUrl = "/html5/dragUpload.do";
		var callUrl = "${pageContext.request.contextPath}/upload.file";
		if( totalCount > 0 ){
			//재업로드하는 경우, 이전 업로드 결과를 초기화 한다.
			fnResultInitialize();
		}else{
			//이미 업로드 완료된 상태 또는 업로드 대상 파일이 없는 경우
			alert('업로드 대상 파일이 없습니다.');
			return; //이후 프로세스 중단
		}
		
		//XMLHttpRequest 객체 생성
		var xhr = new XMLHttpRequest();
		//전송방식 및 호출 URL설정
		xhr.open('POST', callUrl);
		/**
		 * [참고] 파일을 한번에 1개씩 보낼때는 HTTP Header의 'X-File-Name' 속성에 '파일명'을 설정해서 보낼 수 있다.
		 *        특히 한글 파일명을 보낼때, Encoding한 파일명을 보낼때 이용할 수 있다.
		 * --------------------------------------------------------------------------
		 * xhr.setRequestHeader("X-File-Name", encodeURIComponent('요청관리3.jpg')); 
		 * -------------------------------------------------------------------------- 
		 */
		//파일 업로드 진행상태 설정
		xhr.upload.onprogress = function(e) {
			var percentComplete = (e.loaded / e.total) * 100;
		    progressBar.value = percentComplete; //진행바에 진척률 설정
		    progress.innerText = " " + parseInt(percentComplete) + "%"; //진척률(%)을 id="progress" Element에 표기
		};
		
		xhr.onload = function() {
			var callStatus = xhr.status;
			if (callStatus == 200) {
				document.getElementById("resultList").innerHTML = "<center>업로드 성공</center>";
				
				location.href = "${pageContext.request.contextPath}/list.file"
				var result = JSON.parse(xhr.responseText);
				for (var jnx = 0; jnx < result.count; jnx++) {
					if (result[jnx].result == "true") {
						var li = document.createElement("li");
						var a = document.createElement("a");
						a.setAttribute("href", "/html5/upload/" + result[jnx].filename);
						//서버에서 한글깨짐을 방지하기 위해 encoding해서 보냈으로 decoding해서 표기한다.
						a.textContent = decodeURIComponent(result[jnx].filename); 
						a.setAttribute("download", "");
						li.appendChild(a);
						document.getElementById("resultList").appendChild(li);
					}
				}
				
				//전송 완료된 파일정보들을 파일박스에서 지운다. 
				fnClearFiles(); 
			}else if(callStatus == 404){
				alert(callUrl + " 가 존재하지 않습니다.");
			}else if(callStatus == 403){
				alert(callUrl + " 로의 접근이 거부됐습니다.");
			}else{
				alert(callUrl + " 오류가 발생했습니다.");
			}
		};
		
		xhr.onerror = function(e) {
			document.getElementById("resultList").innerHTML = "<center>업로드 실패</center>";
			alert("업로드가 정상적으로 처리되지 않았습니다.");
		};

		//전송
		xhr.send(formData);
	}
</script>
</head>
<body onload="fnOnLoad()">
<form action="${pageContext.request.contextPath}/NewFile.jsp" method="post" enctype="multipart/form-data" id="upload">
	<h2>File Upload</h2>
	<div id="files">
		<ul id="fileList">
			<li id="intro">
				<img src="/html5/contents/fileapi/8/filebox.png" />
				<p class="file-info">업로드 대상 파일들을 드래그해주세요.</p>
			</li>
			<!-- 하기와 같은 정보가 동적으로 추가된다.
			<li>
				<div class="icon css"></div>
				<p class="file-info">파일명</p>
				<p class="file-info">(파일크기)</p>
			</li>
			<li>
				<div class="icon html"></div>
				<p class="file-info">파일명</p>
				<p class="file-info">(파일크기)</p>
			</li>
			 -->
		</ul>
	</div>
	<p><div id="wastebasket">업로드 취소할 파일들은 이곳으로 옮겨주세요</div></p>
	<P><div id="summary" data-total-count="0" data-total-size="0">0개 파일 [총 0 byte]</span></div></p>
	<p><center><progress id="progressBar" max="100" value="0"></progress><span id="progress"> 0%</span></center></p>
	<P><div id="resultList"><center>업로드 결과</center></div></p>
	<center><input type='button' onclick="fnAllClear();" value='전체삭제'/>
	<input id="uploadBtn" type="button" value="업로드" onclick="fnUpload()"/></center>
	</form>

</body>
</html>