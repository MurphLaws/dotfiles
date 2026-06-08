const HUMAN_WRITING_EXAMPLES = [
  {
    id: 1,
    pattern: "Antítesis por negación ('no es A, es B')",
    bad: [
      "La IA no reemplaza tu creatividad, la potencia.",
      "Este aceite no lubrica el motor, lo protege.",
    ],
    good: [
      "La IA hace el trabajo pesado. Lo que ponés vos encima es lo que importa.",
      "Este aceite está formulado para aguantar lo que la mayoría no aguanta.",
    ],
  },
  {
    id: 2,
    pattern: "Personificaciones vacías de conceptos abstractos",
    bad: [
      "El mercado te está pidiendo que te reinventes.",
      "La época te invita a elegir quién querés ser.",
    ],
    good: [
      "Cada vez hay menos margen para hacer siempre lo mismo.",
      "Hoy podés probar cosas que hace diez años eran imposibles sin plata o contactos.",
    ],
  },
  {
    id: 3,
    pattern: "Puntos donde debería haber comas o nexos",
    bad: [
      "Grabé el reel. Lo edité. Lo subí. No pasó nada.",
      "Abrimos a las 7. Cerramos a las 22. Estamos en Juana Koslay.",
    ],
    good: [
      "Grabé el reel, lo edité, lo subí, y no pasó nada.",
      "Abrimos a las 7 y cerramos a las 22, en Juana Koslay.",
    ],
  },
  {
    id: 4,
    pattern: "Mezcla de conceptos sin relación lógica en el mismo párrafo",
    bad: [
      "Vivir con intención significa elegir cada día. Elegir cansa. Por eso muchos no ahorran.",
    ],
    good: [
      "Elegir todo el tiempo cansa. En algún punto el cerebro busca el piloto automático, y ahí es cuando el dinero se escapa solo.",
    ],
  },
  {
    id: 5,
    pattern: "Sentencia universal + consecuencia para el lector",
    bad: [
      "Todo el mundo scrollea sin parar. Si todos scrollean, vos también. Y si vos también, tu atención vale menos cada día.",
    ],
    good: [
      "El scroll infinito no es un hábito, es el diseño del producto. No lo elegiste, te lo instalaron.",
    ],
  },
  {
    id: 6,
    pattern: "Jerga técnica aplicada a contextos humanos",
    bad: [
      "La paternidad es un error de diseño en el sistema de vida líquida.",
      "Tu marca personal está en modo borrador. Es editable.",
    ],
    good: [
      "La paternidad no encaja bien en una vida armada para no comprometerse con nada.",
      "Lo que mostrás hoy no tiene que ser lo que mostrés siempre.",
    ],
  },
  {
    id: 7,
    pattern: "Fragmentos de una sola palabra o nexo como párrafo independiente",
    bad: [
      "Trabajé durante meses en ese proyecto.\nY sin embargo.\nNo llegué a ningún lado.",
      "Lo que te frena no es el tiempo.\nPresencia.\nEso es lo que falta.",
    ],
    good: [
      "Trabajé durante meses en ese proyecto y no llegué a ningún lado, aunque en ese momento juraba que sí.",
      "Lo que te frena no es el tiempo: es que estás en todos lados a la vez y en ninguno del todo.",
    ],
  },
  {
    id: 8,
    pattern: "Argumentos que requieren información que solo existe después de tomar la decisión",
    bad: [
      "Tenés que empezar tu negocio ahora, porque dentro de tres años vas a agradecer haber arrancado hoy.",
    ],
    good: [
      "Empezar ahora tiene un costo real, pero también lo tiene esperar: cada mes que pasa es un mes menos de aprendizaje en cancha.",
    ],
  },
  {
    id: 9,
    pattern: "Repetición del mismo recurso retórico más de dos veces por texto",
    bad: [
      "No es una app, es una herramienta. No es un costo, es una inversión. No es tiempo perdido, es tiempo ganado.",
    ],
    good: [
      "No es una app más: es la diferencia entre improvisar cada semana y tener un sistema que trabaja solo.",
    ],
  },
  {
    id: 10,
    pattern: "Enumeraciones separadas por punto en vez de coma",
    bad: [
      "El pack incluye: diagnóstico. Propuesta. Tres meses de acompañamiento. Soporte por WhatsApp.",
    ],
    good: [
      "El pack incluye diagnóstico, propuesta, tres meses de acompañamiento y soporte por WhatsApp.",
    ],
  },
  {
    id: 11,
    pattern: "Pseudo-poesía sin ritmo real",
    bad: [
      "Te quita tiempo.\nTe quita energía.\nTe quita el foco.\nPero te da algo que ninguna otra cosa da.",
    ],
    good: [
      "Te quita tiempo, energía y foco, y aun así hay algo en eso que ninguna otra cosa te da.",
    ],
  },
  {
    id: 12,
    pattern: "Abuso del guión largo (—)",
    bad: [
      "La consistencia —no el talento— es lo que separa a los que crecen de los que no.",
      "YPF El Salvador —fundada en 1964— sigue siendo la misma estación de siempre.",
    ],
    good: [
      "La consistencia separa a los que crecen de los que no, más que el talento.",
      "YPF El Salvador tiene sesenta años en el mismo lugar, siendo la misma estación de siempre.",
    ],
  },
  {
    id: 13,
    pattern: "Conclusiones que solo repiten lo dicho",
    bad: [
      "En resumen: la constancia importa, el contenido importa y la estrategia importa. Si aplicás todo esto, vas a crecer.",
    ],
    good: [
      "El problema no es saber todo esto. El problema es que sabés todo esto y mañana igual vas a abrir Instagram antes de levantarte de la cama.",
    ],
  },
];

module.exports = HUMAN_WRITING_EXAMPLES;
