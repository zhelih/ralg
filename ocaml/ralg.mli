(** vector type used in the algorithm *)
type vector = float array

(** list of options *)
type options = {

  q1: float; (** adaptive step decrease, default 0.95 *)
  q2: float; (** adaptive step increase, default 1.2 *)
  nh: int;   (** adaptive step max steps, default 3 *)

  alpha: float; (** space dillution parameter, default 2 *)

  itermax: int; (** maximum number of iterations, default 10_000 *)
  stepmax: int; (** maximum number of adaptive step iteriations, default 500 *)

  stepmin: float; (** minimum value for the step to stop, default 1.e-15 *)
  b_mult_grad_min: float; (** minimum value B times gradient to stop, default 1.e-20 *)
  reset: float; (** minimum value for maxtrix B norm to reset, default 1.e-18 *)

  initstep: float; (** initial adaptive step value, default 1. *)
  b_init: float; (** B matrix init value, default 1. *)

  is_monotone: bool; (** flag to indicate if convergence is monotone; false will trigger additional solution tracking; default true *)

  output: bool; (** print to stdout, default true *)
  output_iter: int; (** iterations to print, default 500 *)
}

val default_options : options

(** args: options, callback taking points as input and returning value and gradient (vector), starting point. Output of the algorithm is vector *)
val ralg : options -> ( vector -> float * vector ) -> vector -> float * vector
