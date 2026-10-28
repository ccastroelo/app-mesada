/// Regra de partida criada junto com a família (sem id: o banco gera).
class RuleSeed {
  const RuleSeed(this.description, this.valueCents);

  final String description;
  final int valueCents;
}

/// As 20 regras do app antigo (`*.lproj/faltas.plist`), em centavos.
/// Só correções de ortografia e espaços; o texto continua o do legado.
/// pt-PT usa a lista em português: o legado tinha a mesma lista nos dois.
List<RuleSeed> defaultRulesFor(String languageCode) {
  final descriptions = switch (languageCode) {
    'en' => _en,
    'es' => _es,
    _ => _pt,
  };
  assert(descriptions.length == _valuesInCents.length);
  return [
    for (var i = 0; i < descriptions.length; i++)
      RuleSeed(descriptions[i], _valuesInCents[i]),
  ];
}

const _valuesInCents = [
  50, 150, -50, -100, -50, -50, -50, -50, -50, -75, //
  -50, -25, -25, -50, -200, -50, -50, -50, -150, -100,
];

const _pt = [
  'Arrumar a cama',
  'Tirar nota 10',
  'Deixar a luz acesa',
  'Não fazer o dever de casa',
  'Deixar os brinquedos jogados',
  'Deixar a geladeira aberta',
  'Não escovar os dentes',
  'Deixar roupa ou toalha largada no chão',
  'Atrasar para o inglês ou para a escola',
  'Não almoçar ou jantar',
  'Reclamar para ir ao inglês ou à escola',
  'Não tomar banho',
  'Não puxar a descarga',
  'Não colocar o cinto de segurança',
  'Tirar nota baixa na escola ou no inglês',
  'Comer fora da mesa',
  'Deixar a TV ou outros aparelhos ligados',
  'Deixar a torneira ou o chuveiro aberto ou pingando',
  'Xingar, brigar ou bater',
  'Mentir',
];

const _en = [
  'Make the bed',
  'Grade A at school',
  'Leave the light on',
  "Don't do the homework",
  'Leave the toys on the floor',
  'Leave the fridge open',
  'Do not brush the teeth',
  'Leave cloth or towel on the floor',
  'Delay to school',
  'No lunch or dinner',
  'Complaining to go to school',
  'Do not bathe',
  'Do not flush the toilet',
  'Do not put the seatbelt',
  'Bad grade at school',
  'Eating off the table',
  'Leave the TV or other devices on',
  'Leave the faucet or shower open or dripping',
  'Swearing, fighting or hitting',
  'Lie',
];

const _es = [
  'Hacer la cama',
  'Obtener la máxima calificación en la escuela',
  'Dejar la luz encendida',
  'No hacer los deberes de casa',
  'Dejar los juguetes desordenados',
  'Dejar la nevera abierta',
  'No cepillarse los dientes',
  'Dejar la ropa o una toalla en el suelo',
  'Retraso a la escuela',
  'No comer o no cenar',
  'Quejándose de ir a la escuela',
  'No ducharse',
  'No tirar de la cadena',
  'No abrocharse el cinturón de seguridad',
  'Recibir una mala calificación en la escuela',
  'No comer en la mesa',
  'Dejar la televisión u otros aparatos encendidos',
  'Dejar el grifo o la ducha abierto o goteando',
  'Insultar, pelear o golpear',
  'Mentir',
];
