enum InstrumentType {
  fanAnemometer('Fan Anemometer'),
  biramAnemometer('Biram Anemometer'),
  liquidManometer('Liquid Manometer'),
  hygrometer('Hygrometer'),
  barometer('Barometer'),
  windSpeedMeter('Wind-Speed Meter'),
  other('Other');

  const InstrumentType(this.label);
  final String label;
}

enum MovementType {
  gearedTransmission('Geared Transmission'),
  jeweledBearings('Jeweled Bearings'),
  frictionBrake('Friction-Brake Start/Stop'),
  springDriven('Spring-Driven'),
  unknown('Unknown');

  const MovementType(this.label);
  final String label;
}

enum ConditionState {
  operational('Operational'),
  displayOnly('Display Only'),
  vanesIntact('Vanes Intact — Non-Functional'),
  damagedVanes('Damaged / Bent Vanes'),
  unknown('Unknown');

  const ConditionState(this.label);
  final String label;
}
