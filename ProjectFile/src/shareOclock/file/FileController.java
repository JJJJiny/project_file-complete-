package shareOclock.file;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.tomcat.util.http.fileupload.FileItem;
import org.apache.tomcat.util.http.fileupload.FileUploadException;
import org.apache.tomcat.util.http.fileupload.disk.DiskFileItemFactory;
import org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload;

import com.google.gson.Gson;
import com.google.gson.JsonObject;



@WebServlet("*.file")
public class FileController extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("utf-8");
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html;charset=utf-8");
		String requestURI = request.getRequestURI();
		String cxtPath = request.getContextPath();
		String cmd = requestURI.substring(cxtPath.length());
		try {
			if(cmd.contentEquals("/upload.file")) {
				System.out.println("upload.file에 도착했나요?");
				String uploadPath = request.getServletContext().getRealPath("/files"); //파일경로를 알아야한다. 뒤에 붙이는기능을하기 때문에 /files를 붙인다. //getServletContext() : ServletContainer의 맥락 환경정보 관리 인스턴스
				//client가 경로를 보내고 서버가 가져와 db에 경로를 저장하기 위해 uploadPath 구함
				File uploadFilePath = new File(uploadPath);
				if(!uploadFilePath.exists()) {
					uploadFilePath.mkdir();
				} 
				System.out.println(uploadPath);

				int maxSize = 1024*1024*10;	
				MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF8", new DefaultFileRenamePolicy()); //라이브러리 필요하고 여러가지의 라이브러리가 있는데 Spring을 사용한다면 아파치업로드파일 아니라면 cos사용				
				
	
				Enumeration fileNames = multi.getFileNames();	
				while(fileNames.hasMoreElements()){
					String input_file = (String)fileNames.nextElement();
					
					String fileName = multi.getFilesystemName("input_file");
					String oriFileName = multi.getOriginalFileName("input_file");
					System.out.println(fileName); //파일을 찾을 때의 경로
					System.out.println(oriFileName); //client에 보여줄 때
					if(fileName == null) continue;
					//String f_writer = (String) request.getSession().getAttribute("loginInfo");
					String f_writer = "jin";
					FilesDTO dto = new FilesDTO(0,fileName,oriFileName,null,f_writer,0,1);
					int result = FilesDAO.getInstance().insert(dto);
					

					JsonObject jso = new JsonObject();
					jso.addProperty("fileName",fileName );
				
					System.out.println(jso);
					Gson g = new Gson();
					response.getWriter().append(jso.toString());
				}
					System.out.println("보내기 완료");
				
					
				}else if(cmd.contentEquals("/list.file")) {
					System.out.println("list.file에 도착했나요?");
					List<FilesDTO> list = FilesDAO.getInstance().getAllFiles();
					request.setAttribute("list", list);
					request.getRequestDispatcher("file/list.jsp").forward(request, response);
					//response.sendRedirect("file/list.jsp");
					System.out.println("도착완료");
				}else if(cmd.contentEquals("/download.file")) {
					System.out.println("ㄷ촥했나용?");
					String fileName = request.getParameter("fileName");
					System.out.println(fileName);
					String path = request.getServletContext().getRealPath("/files");//getServletContext() -> application
					String fullPath = path + "/" + fileName;
					System.out.println(fullPath);

					//int downloadCount = FilesDAO.getInstance().downloadCount(fileName);
					//JsonObject jso = new JsonObject();
					//jso.addProperty("downloadCount", downloadCount);
					//System.out.println(jso);
					//Gson g = new Gson();
					//response.getWriter().append(jso.toString());
					//int f_seq = Integer.parseInt(request.getParameter("f_seq"));
					//System.out.println(f_seq);
					//FilesDTO dto = FilesDAO.getInstance().getFileByfileName(f_seq);
					//int result = dto.getF_seq();

					File f = new File(fullPath);
					try(

							FileInputStream fis= new FileInputStream(f);
							DataInputStream fileDis= new DataInputStream(fis);
							ServletOutputStream sos = response.getOutputStream();
							){
						byte[] fileContents = new byte[(int)f.length()];
						fileDis.readFully(fileContents);
						//------------------------------------------------------
						response.reset();
						response.setContentType("application/octet-stream");
						String encFileName = new String(fileName.getBytes("utf8"),"iso-8859-1");
						response.setHeader("Content-Disposition", "attachment; filename=\""+encFileName+"\""); 
						response.setHeader("Content-Length", String.valueOf(f.length()));
						sos.write(fileContents);
						sos.flush();	
					}

				}else if(cmd.contentEquals("/downloadCount.file")) {				
					System.out.println("countrdjasklfjka");
					int f_seq = Integer.parseInt(request.getParameter("f_seq"));
					int downloadCount = FilesDAO.getInstance().downloadCount(f_seq);

					System.out.println(downloadCount);
					if(downloadCount > 0) {
						JsonObject jso = new JsonObject();
						int dCnt = FilesDAO.getInstance().getFileByfileSeq(f_seq);
						jso.addProperty("dCnt", dCnt);
						jso.addProperty("f_seq", f_seq);
						Gson g = new Gson();
						String str = g.toJson(jso);
						System.out.println(str);
						response.getWriter().append(str);
						System.out.println(dCnt);
						System.out.println("성공");
					}else {
						System.out.println("실패");
					}
				}
				else if(cmd.contentEquals("/delete.file")) {
					System.out.println("delete.file에 도착했나요?");
					try {
						String ca = request.getParameter("checkArray");
						//리스트들의 f_seq들을 찾아 삭제 리스트들의 숫자를 꺼내서 하나하나 삭제해야한다. 
						System.out.println("ddd");
						System.out.println(ca);
						ca = ca.replaceAll("\"", "");
						ca=ca.replace("[", "");
						ca=ca.replace("]", "");
						System.out.println(ca);
						String [] words = ca.split(",");
						System.out.println(Integer.parseInt(words[0]));
						//int result = 0;
						JsonObject jo= new JsonObject();
						
						for(int i =0; i<words.length; i++) {
							int f_seq = Integer.parseInt(words[i]);
							System.out.println(f_seq);
							System.out.println("메소드전");
							int result = FilesDAO.getInstance().delete(f_seq);
							System.out.println(result);
							System.out.println("메소드후");
							//jo.addProperty("count"+i, "success");
							if(result > 0) {					
								System.out.println("성공이잖오");
								jo.addProperty("count"+i, "success");
								System.out.println("result성공");
							}else {
								jo.addProperty("count"+i, "fail");
								break;
							}
						}
						response.getWriter().append(jo.toString());
						//int f_seq = Integer.parseInt(words[0]);
						//System.out.println(f_seq);
						//List<Integer> list = Arrays.asList(ca.split(","));
						//System.out.println(list);
						//					for(int i = 0; i<list.size(); i++) {
						//						System.out.println(list.get(i));
						//
						//						System.out.println("삭제");

						//
						//
						//					}
						//JsonParser parser = new JsonParser();
						//JsonElement data= parser.parse(ca);
						//JsonArray ja = data.getAsJsonArray();
						///for(int i =0; i<ja.size(); i++) {
						//System.out.println(ja.get(i)); 

						//}


					} catch (Exception e) {
						response.sendRedirect("error.jsp");
						e.printStackTrace();
					}
				}
			}catch (Exception e) {
				e.printStackTrace();

			}
		}
		protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

			doGet(request, response);
		}

	}
