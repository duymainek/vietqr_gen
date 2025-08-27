/// A comprehensive, type-safe enum of Vietnamese banks supported by VietQR.
/// Each enum value holds the official name and the bank's BIN code.
enum Bank {
  acb('ACB', '970416'),
  agribank('Agribank', '970405'),
  bacABank('Bac A Bank', '970409'),
  baoVietBank('Bao Viet Bank', '970438'),
  bidv('BIDV', '970418'),
  dongABank('Dong A Bank', '970406'),
  eximbank('Eximbank', '970431'),
  gpBank('GPBank', '970408'),
  hdBank('HDBank', '970437'),
  hongLeong('Hong Leong Vietnam', '970442'),
  kienlongbank('Kienlongbank', '970452'),
  lpBank('LPBank (LienVietPostBank)', '970449'),
  mbBank('MBBank', '970422'),
  msb('MSB', '970426'),
  namABank('Nam A Bank', '970428'),
  ncb('NCB', '970419'),
  ocb('OCB', '970448'),
  oceanbank('Oceanbank', '970414'),
  pgBank('PG Bank', '970430'),
  pvcomBank('PVcomBank', '970412'),
  sacombank('Sacombank', '970403'),
  saigonbank('Saigonbank', '970400'),
  scb('SCB', '970429'),
  seABank('SeABank', '970440'),
  shb('SHB', '970443'),
  techcombank('Techcombank', '970407'),
  tpBank('TPBank', '970423'),
  vib('VIB', '970441'),
  vietCapitalBank('VietCapitalBank (BVBank)', '970454'),
  vietcombank('Vietcombank', '970436'),
  vietinbank('Vietinbank', '970415'),
  vpBank('VPBank', '970432'),
  vrb('VRB', '970421');

  /// The official name of the bank.
  final String name;

  /// The Bank Identification Number (BIN) used for VietQR transactions.
  final String bin;

  const Bank(this.name, this.bin);
}
