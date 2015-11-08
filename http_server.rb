# A basic ruby webserver off of http://blogs.msdn.com/b/abhinaba/archive/2005/10/14/474841.aspx
# All credit to the author, this file exists as some example code for socket programming in ruby for the project

class HttpServer
  def initialize(session, request, basePath, logger)
    @session = session
    @request = request
    @basePath = basePath
		@logger = logger
  end
	
	# Returns the full path for an http request
  def getFullPath()
    fileName = nil
    if @request =~ /GET .* HTTP.*/
      fileName = @request.gsub(/GET /, '').gsub(/ HTTP.*/, '')
    end
    fileName = fileName.strip
    unless fileName == nil
      fileName = @basePath + fileName
      fileName = File.expand_path(fileName, @defaultPath)
    end
    fileName << "index.html" if  File.directory?(fileName)
    return fileName
  end
	
	# Returns the associated file for an http request, handles bad requests
  def serve()
    @fullPath = getFullPath()
    src = nil
    begin
      if File.exist?(@fullPath) and File.file?(@fullPath)
        if @fullPath.index(@basePath) == 0 #path should start with base path
          contentType = getContentType(@fullPath)
          @session.print "HTTP/1.1 200/OK\r\nServer: Makorsha\r\nContent-type: #{contentType}\r\n\r\n"
          src = File.open(@fullPath, "rb")
          while (not src.eof?)
            buffer = src.read(256)
            @session.write(buffer)
          end
          src.close
          src = nil
        else
          @session.print "HTTP/1.1 404/Object Not Found\r\n\r\n"
        end
      else
        @session.print "HTTP/1.1 404/Object Not Found\r\n\r\n"
      end
    ensure
      src.close unless src == nil
      @session.close
    end
  end
	
	# returns content type for some path
  def getContentType(path)
    ext = File.extname(path)
    return "text/html"  if ext == ".html" or ext == ".htm"
    return "text/plain" if ext == ".txt"
    return "text/css"   if ext == ".css"
    return "image/jpeg" if ext == ".jpeg" or ext == ".jpg"
    return "image/gif"  if ext == ".gif"
    return "image/bmp"  if ext == ".bmp"
    return "text/plain" if ext == ".rb"
    return "text/xml"   if ext == ".xml"
    return "text/xml"   if ext == ".xsl"
    return "text/html"
  end
end
