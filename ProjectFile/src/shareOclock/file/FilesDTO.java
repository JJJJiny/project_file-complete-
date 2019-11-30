package shareOclock.file;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class FilesDTO {
	private int f_seq;
	private String file_name;
	private String original_file_name;
	private Timestamp f_write_date;
	private String f_writer;
	private int f_downloadCnt;
	private int pro_seq;
	public FilesDTO() {
		super();
	}
	public FilesDTO(int f_seq, String file_name, String original_file_name, Timestamp f_write_date, String f_writer,
			int f_downloadCnt, int pro_seq) {
		super();
		this.f_seq = f_seq;
		this.file_name = file_name;
		this.original_file_name = original_file_name;
		this.f_write_date = f_write_date;
		this.f_writer = f_writer;
		this.f_downloadCnt = f_downloadCnt;
		this.pro_seq = pro_seq;
	}
	public int getF_seq() {
		return f_seq;
	}
	public void setF_seq(int f_seq) {
		this.f_seq = f_seq;
	}
	public String getFile_name() {
		return file_name;
	}
	public void setFile_name(String file_name) {
		this.file_name = file_name;
	}
	public String getOriginal_file_name() {
		return original_file_name;
	}
	public void setOriginal_file_name(String original_file_name) {
		this.original_file_name = original_file_name;
	}
	public Timestamp getF_write_date() {
		return f_write_date;
	}
	public void setF_write_date(Timestamp f_write_date) {
		this.f_write_date = f_write_date;
	}
	public String getF_writer() {
		return f_writer;
	}
	public void setF_writer(String f_writer) {
		this.f_writer = f_writer;
	}
	public int getF_downloadCnt() {
		return f_downloadCnt;
	}
	public void setF_downloadCnt(int f_downloadCnt) {
		this.f_downloadCnt = f_downloadCnt;
	}
	public int getPro_seq() {
		return pro_seq;
	}
	public void setPro_seq(int pro_seq) {
		this.pro_seq = pro_seq;
	}
	public String getFormedDate() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
		long write_date = this.f_write_date.getTime(); // 작성된 시간
		long current_date = System.currentTimeMillis(); // 현재 시간
		long gapTime = (current_date - write_date)/1000;
		if(gapTime < 300) {
			return "5분이내";
		}else if(300 <= gapTime && gapTime <= 3600) {
			return "1시간 이내";
		}else {
			return sdf.format(this.f_write_date);
		}
	}

}
