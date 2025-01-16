package fi.oph.opintopolku.ovara;

import fi.oph.opintopolku.ovara.config.Config;
import fi.oph.opintopolku.ovara.service.LampiSiirtajaService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.regions.Region;

public class App {

  public static final Logger LOG = LoggerFactory.getLogger(App.class);

  public static void main(String[] args) throws Exception {

    LOG.info("Aloitetaan Ovaran tietojen siirto Lampeen");

    Config config =
        new Config(
            System.getenv("POSTGRES_HOST"),
            Integer.valueOf(System.getenv("POSTGRES_PORT")),
            System.getenv("DB_USERNAME"),
            System.getenv("DB_PASSWORD"),
            System.getenv("OVARA_LAMPI_SIIRTAJA_BUCKET"),
            System.getenv("LAMPI_S3_BUCKET"),
            Region.EU_WEST_1,
            "fulldump/ovara/v1/");

    LampiSiirtajaService service = new LampiSiirtajaService(config);
    service.run();

    LOG.info("Ovaran tietojen siirto Lampeen valmistui");
  }
}
