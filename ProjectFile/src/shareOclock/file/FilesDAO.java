package shareOclock.file;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.apache.tomcat.dbcp.dbcp2.BasicDataSource;


public class FilesDAO {
	private static FilesDAO instance;
	private BasicDataSource bds = new BasicDataSource();

	private FilesDAO() {
		bds.setDriverClassName("oracle.jdbc.driver.OracleDriver");
		bds.setUrl("jdbc:oracle:thin:@localhost:1521:xe");
		bds.setUsername("manager");
		bds.setPassword("manager");
		bds.setInitialSize(30);
	}
	public synchronized static FilesDAO getInstance(){
		if(FilesDAO.instance == null){
			FilesDAO.instance = new FilesDAO(); 
		}
		return FilesDAO.instance;
	}
	private Connection getConnection() throws Exception{
		return bds.getConnection();
	}
	public int insert(FilesDTO dto) throws Exception{
		String sql = "insert into tb_file values(f_seq.nextval,?,?,sysdate,?,0,?)";
		try(
				Connection con = this.getConnection();
				PreparedStatement pstat = con.prepareStatement(sql);
				){
			pstat.setString(1, dto.getFile_name());
			pstat.setString(2, dto.getOriginal_file_name());
			pstat.setString(3, dto.getF_writer());
			pstat.setInt(4, dto.getPro_seq());
			int result = pstat.executeUpdate();
			con.commit();
			return result;
		}
	}
	public List<FilesDTO> getAllFiles() throws Exception{
		String sql = "select * from tb_file";
		try(
				Connection con = this.getConnection();
				PreparedStatement pstat = con.prepareStatement(sql);
				ResultSet rs = pstat.executeQuery();
				){
			List<FilesDTO> list = new ArrayList<>();
			while(rs.next()) {
				int f_seq = rs.getInt("f_seq");
				String file_name = rs.getString("file_name");
				String original_file_name = rs.getString("original_file_name");
				Timestamp f_writeDate = rs.getTimestamp("f_writeDate");
				String f_writer = rs.getString("f_writer");
				int f_downloadCnt = rs.getInt("f_downloadCnt");
				int pro_seq = rs.getInt("pro_seq");
				FilesDTO dto = new FilesDTO(f_seq, file_name, original_file_name, f_writeDate, f_writer, f_downloadCnt , pro_seq);
				list.add(dto);
			}
			return list;
		}
	}
	
	public int getFileByfileSeq(int f_seq) throws Exception{
		String sql = "select f_downloadCnt from tb_file where f_seq = ?";
		try(
				Connection con = this.getConnection();
				PreparedStatement pstat = con.prepareStatement(sql);
				){
			pstat.setInt(1, f_seq);
			try(
					ResultSet rs = pstat.executeQuery();
					){
				if(rs.next()) {
					int f_downloadCnt = rs.getInt("f_downloadCnt");			
					return f_downloadCnt ;
				}
			}
		}
		return 0;
	}
	public int downloadCount(int f_seq) throws Exception{
		String sql = "update tb_file set f_downloadCnt = f_downloadCnt+1 where f_seq =?";
		try(
				Connection con = this.getConnection();
				PreparedStatement pstat= con.prepareStatement(sql);
				){
			pstat.setInt(1, f_seq);
			int result = pstat.executeUpdate();
			con.commit();
			return result;
		}
	}
	public int delete(int f_seq) throws Exception{
		String sql = "delete from tb_file where f_seq = ?";
		try(
				Connection con = this.getConnection();
				PreparedStatement pstat = con.prepareStatement(sql);
				){
			pstat.setInt(1, f_seq);
			int result = pstat.executeUpdate();
			con.commit();
			return result;	
		}
	}

}
