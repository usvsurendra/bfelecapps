class MotorModel {
  final String eqptName;
  final String kw;
  final String statrVol;
  final String statrCur;
  final String rotorVol;
  final String rotorCur;
  final String speed;
  final String make;
  final String mounting;
  final String de;
  final String nde;
  final String frame;
  final String area;
  final String location;
  final String coupling;
  final String remarks;

  MotorModel({
    required this.eqptName,
    required this.kw,
    required this.statrVol,
    required this.statrCur,
    required this.rotorVol,
    required this.rotorCur,
    required this.speed,
    required this.make,
    required this.mounting,
    required this.de,
    required this.nde,
    required this.frame,
    required this.area,
    required this.location,
    required this.coupling,
    required this.remarks,
  });

  factory MotorModel.fromCsvRow(List<dynamic> row) {
    // Ensure the row has exactly 16 columns to prevent out-of-bounds errors
    final List<String> cols = row.map((e) => e.toString().trim()).toList();
    while (cols.length < 16) {
      cols.add('');
    }

    return MotorModel(
      eqptName: cols[0],
      kw: cols[1],
      statrVol: cols[2],
      statrCur: cols[3],
      rotorVol: cols[4],
      rotorCur: cols[5],
      speed: cols[6],
      make: cols[7],
      mounting: cols[8],
      de: cols[9],
      nde: cols[10],
      frame: cols[11],
      area: cols[12],
      location: cols[13],
      coupling: cols[14],
      remarks: cols[15],
    );
  }
}
