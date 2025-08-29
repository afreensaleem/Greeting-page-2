package helper;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class FlaskClient {
  public static String sendImageToFlask(InputStream imageInputStream) throws IOException {
    String hfUrl = "https://api-inference.huggingface.co/models/AfreenSaleem/background-remover";
    String accessToken = System.getenv("HUGGINGFACE_TOKEN");
    if (accessToken == null || accessToken.isEmpty()) {
      throw new IOException("HUGGINGFACE_TOKEN environment variable is not set");
    }

    URL url = new URL(hfUrl);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setDoOutput(true);
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/octet-stream");
    conn.setRequestProperty("Authorization", "Bearer " + accessToken);
    conn.setConnectTimeout(15000);
    conn.setReadTimeout(45000);

    // Write raw image bytes
    try (OutputStream output = conn.getOutputStream()) {
      byte[] buffer = new byte[8192];
      int bytesRead;
      while ((bytesRead = imageInputStream.read(buffer)) != -1) {
        output.write(buffer, 0, bytesRead);
      }
    }

    int status = conn.getResponseCode();
    if (status != HttpURLConnection.HTTP_OK) {
      StringBuilder errorBuilder = new StringBuilder();
      try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
        String errorLine;
        while ((errorLine = br.readLine()) != null) {
          errorBuilder.append(errorLine.trim());
        }
      }
      throw new IOException("Hugging Face API error: " + status + " - " + errorBuilder.toString());
    }

    // Read response and encode to base64
    try (InputStream responseStream = conn.getInputStream()) {
      byte[] bytes = responseStream.readAllBytes();
      String base64Image = java.util.Base64.getEncoder().encodeToString(bytes);
      return base64Image;
    } finally {
      conn.disconnect();
    }
  }

  public static void main(String[] args) {
    if (args.length < 1) {
      System.err.println("Usage: java -cp \"lib/json-20240303.jar:.\" helper.FlaskClient <image-path>");
      return;
    }
    try {
      InputStream imageInputStream = new FileInputStream(args[0]);
      String result = sendImageToFlask(imageInputStream);
      System.out.println("Response: " + result);
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}
