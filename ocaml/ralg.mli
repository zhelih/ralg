(** vector type used in the algorithm *)
type vector = float array

(** list of options *)
type options (* TODO, structure of primitive types *)

(** args: options, callback taking points as input and returning value and gradient (vector), starting point. Output of the algorithm is vector *)
val ralg : options -> ( vector -> float * vector ) -> vector -> float * vector
