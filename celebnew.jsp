<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="helper.FlaskClient" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Base64" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Our Anniversary</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Anton+SC&family=Audiowide&family=Playwrite+US+Trad:wght@100..400&display=swap" rel="stylesheet">
</head>
<body>
<%
  String name = "";
  String tagline = "";
  String base64Image = "";
  String fileType = "";
  String bgRemovedBase64 = "";

  try {
    if (ServletFileUpload.isMultipartContent(request)) {
      DiskFileItemFactory factory = new DiskFileItemFactory();
      factory.setSizeThreshold(10 * 1024 * 1024);
      factory.setRepository(new java.io.File(System.getProperty("java.io.tmpdir")));
      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setFileSizeMax(50 * 1024 * 1024);
      upload.setSizeMax(100 * 1024 * 1024);

      List<FileItem> items = upload.parseRequest(request);
      for (FileItem item : items) {
        if (item.isFormField()) {
          if ("name1".equals(item.getFieldName())) name = item.getString("UTF-8");
          if ("name2".equals(item.getFieldName())) tagline = item.getString("UTF-8");
        } else {
          String fieldName = item.getFieldName();
          InputStream inputStream = item.getInputStream();
          byte[] bytes = IOUtils.toByteArray(inputStream);
          if ("mainImage".equals(fieldName)) {
            base64Image = Base64.getEncoder().encodeToString(bytes);
            fileType = item.getContentType();
          } else if ("bgImage".equals(fieldName)) {
            try {
              bgRemovedBase64 = FlaskClient.sendImageToFlask(new ByteArrayInputStream(bytes));
            } catch (Exception e) {
              out.println("Error calling Flask API: " + e.getMessage());
              e.printStackTrace(new java.io.PrintWriter(out));
            }
          }
        }
      }
    } else {
      out.println("Error: Request is not multipart/form-data");
    }
  } catch (Exception e) {
    out.println("Error processing form: " + e.getMessage());
    e.printStackTrace(new java.io.PrintWriter(out));
  }
%>

<h1>Hello <%= name != null ? name : "Guest" %></h1>
<h2><%= tagline != null ? tagline : "" %></h2>

<div>
  <% if (base64Image != null && !base64Image.isEmpty()) { %>
    <h3>Main Image:</h3>
    <img src="data:<%= fileType != null ? fileType : "image/png" %>;base64,<%= base64Image %>" style="max-width:200px;"/>
  <% } %>
</div>

<div>
  <% if (bgRemovedBase64 != null && !bgRemovedBase64.isEmpty()) { %>
    <h3>Background Removed Image:</h3>
    <img src="data:image/png;base64,<%= bgRemovedBase64 %>" style="max-width:200px;"/>
  <% } else { %>
    <p>No background removed image yet.</p>
  <% } %>
</div>
</body>
</html>
