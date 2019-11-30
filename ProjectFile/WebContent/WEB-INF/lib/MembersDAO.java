package kh.backend.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class MembersDAO {
	public Connection getConnection() throws Exception {
		Class.forName("oracle.jdbc.driver.OracleDriver");
		String url ="jdbc:oracle:thin:@localhost:1521:xe";
		String id="manager";
		String pw="manager";
		return DriverManager.getConnection(url,id,pw);
	}
	public boolean isIdAvailble(String id) throws Exception{
		String sql = "select * from members where id = ?";
		try(
				Connection con = this.getConnection();
				PreparedStatement pstat = con.prepareStatement(sql);
				){
			pstat.setString(1, id);
			try(
					ResultSet rs = pstat.executeQuery(); //하나가 들어있거나 안들어있거나 그러므로 while문을 돌릴 필요가 없다.
					){
				boolean result = rs.next();
				return !result; //메서드의 이름과 결과가 일치해야 가독성이 있다.
			}
		}
	}
}
