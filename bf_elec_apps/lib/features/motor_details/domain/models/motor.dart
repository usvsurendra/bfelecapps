class Motor {
  final String eqptName;
  final String kw;
  final String statrVol;
  final String statrCur;
  final String rotorVol;
  final String rotorCur;
  final String speed;
  final String make;
  final String mntng;
  final String de;
  final String nde;
  final String frame;
  final String area;
  final String location;
  final String coupling;
  final String remarks;

  const Motor({
    required this.eqptName,
    required this.kw,
    required this.statrVol,
    required this.statrCur,
    required this.rotorVol,
    required this.rotorCur,
    required this.speed,
    required this.make,
    required this.mntng,
    required this.de,
    required this.nde,
    required this.frame,
    required this.area,
    required this.location,
    required this.coupling,
    required this.remarks,
  });

  factory Motor.fromCsvRow(List<String> row) {
    String getSafe(int index) => index < row.length ? row[index].trim() : '';

    return Motor(
      eqptName: getSafe(0),
      kw: getSafe(1),
      statrVol: getSafe(2),
      statrCur: getSafe(3),
      rotorVol: getSafe(4),
      rotorCur: getSafe(5),
      speed: getSafe(6),
      make: getSafe(7),
      mntng: getSafe(8),
      de: getSafe(9),
      nde: getSafe(10),
      frame: getSafe(11),
      area: getSafe(12),
      location: getSafe(13),
      coupling: getSafe(14),
      remarks: getSafe(15),
    );
  }

  Map<String, String> toMap() {
    return {
      'EQPT. NAME': eqptName,
      'KW': kw,
      'STATOR VOLT (V)': statrVol,
      'STATOR CURR (A)': statrCur,
      'ROTOR VOLT (V)': rotorVol,
      'ROTOR CURR (A)': rotorCur,
      'SPEED (RPM)': speed,
      'MAKE': make,
      'MOUNTING': mntng,
      'D.E. BRG': de,
      'N.D.E. BRG': nde,
      'FRAME': frame,
      'AREA': area,
      'LOCATION': location,
      'COUPLING': coupling,
      'REMARKS': remarks,
    };
  }
}
