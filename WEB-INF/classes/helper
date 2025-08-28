import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import org.json.JSONArray;
import org.json.JSONObject;

public class FlaskClient {
  public static String sendImageToFlask(InputStream imageInputStream) throws IOException {
    String hfUrl = "https://afreensaleem-background-remover.hf.space/api/predict";
    String accessToken = System.getenv("HUGGINGFACE_TOKEN");
    if (accessToken == null || accessToken.isEmpty()) {
      throw new IOException("HUGGINGFACE_TOKEN environment variable is not set");
    }

    // Read image bytes and encode to base64 with MIME prefix
    byte[] bytes = imageInputStream.readAllBytes();
    String base64Image = java.util.Base64.getEncoder().encodeToString(bytes);
    String fullBase64 = "data:image/png;base64," + base64Image;

    // Create JSON payload
    JSONObject payload = new JSONObject();
    JSONArray dataArray = new JSONArray();
    dataArray.put(fullBase64);
    payload.put("data", dataArray);

    URL url = new URL(hfUrl);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setDoOutput(true);
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/json");
    conn.setRequestProperty("Authorization", "Bearer " + accessToken);
    conn.setConnectTimeout(15000);
    conn.setReadTimeout(45000);

    // Write JSON payload
    try (OutputStream output = conn.getOutputStream()) {
      output.write(payload.toString().getBytes(StandardCharsets.UTF_8));
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

    // Read response
    StringBuilder responseBuilder = new StringBuilder();
    try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
      String responseLine;
      while ((responseLine = br.readLine()) != null) {
        responseBuilder.append(responseLine.trim());
      }
    }
    conn.disconnect();

    // Parse JSON and extract base64
    JSONObject responseJson = new JSONObject(responseBuilder.toString());
    String outputFullBase64 = responseJson.getJSONArray("data").getString(0);
    String outputBase64 = outputFullBase64.split(",")[1]; // Remove MIME prefix
    return outputBase64;
  }

  public static void main(String[] args) {
    if (args.length < 1) {
      System.err.println("Usage: java -cp \"lib/json-20240303.jar:.\" FlaskClient <image-path>");
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
