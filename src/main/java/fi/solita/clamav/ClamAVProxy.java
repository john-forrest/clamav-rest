package fi.solita.clamav;

import java.io.IOException;

import com.fasterxml.jackson.databind.util.JSONPObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import javax.json.Json;
import javax.json.JsonObject;
import java.nio.charset.StandardCharsets;

@RestController
public class ClamAVProxy {

  @Value("${clamd.host}")
  private String hostname;

  @Value("${clamd.port}")
  private int port;

  @Value("${clamd.timeout}")
  private int timeout;

  /**
   * @return Clamd status.
   */
  @RequestMapping("/")
  public String ping() throws IOException {
    ClamAVClient a = new ClamAVClient(hostname, port, timeout);
    return "Clamd responding: " + a.ping() + "\n";
  }

  /**
   * @return Clamd scan result
   */
  @RequestMapping(value="/scan", method=RequestMethod.POST)
  public @ResponseBody String handleFileUpload(@RequestParam("name") String name,
                                               @RequestParam("file") MultipartFile file) throws IOException{
    if (!file.isEmpty()) {
      ClamAVClient a = new ClamAVClient(hostname, port, timeout);
      byte[] r = a.scan(file.getInputStream());
      return "Everything ok : " + ClamAVClient.isCleanReply(r) + "\n";
    } else throw new IllegalArgumentException("empty file");
  }

    /**
     * @return Clamd scan result (raw result)
     */
    @RequestMapping(value="/rscan", method=RequestMethod.POST)
    public @ResponseBody String rawHandleFileUpload(@RequestParam("name") String name,
                                                    @RequestParam("file") MultipartFile file) throws IOException{
        if (!file.isEmpty()) {
            ClamAVClient a = new ClamAVClient(hostname, port, timeout);
            byte[] r = a.scan(file.getInputStream());
            String strResult = new String(r, StandardCharsets.US_ASCII).replace("\0", "");
            return strResult;
        } else throw new IllegalArgumentException("empty file");
    }

    /**
     * @return Clamd scan result (raw result)
     */
    @RequestMapping(value="/jscan", method=RequestMethod.POST)
    public @ResponseBody String jsonHandleFileUpload(@RequestParam("name") String name,
                                                    @RequestParam("file") MultipartFile file) throws IOException{
        if (!file.isEmpty()) {
            ClamAVClient a = new ClamAVClient(hostname, port, timeout);
            byte[] r = a.scan(file.getInputStream());
            Boolean reply = ClamAVClient.isCleanReply(r);
            String strResult = new String(r, StandardCharsets.US_ASCII).replace("\0", "");
            JsonObject obj = Json.createObjectBuilder().
                    add("reply", reply).
                    add("raw", strResult).build();
            return obj.toString();
        } else throw new IllegalArgumentException("empty file");
    }

}
