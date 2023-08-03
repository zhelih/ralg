open Ralg

let ralg_options = default_options ()

let sign = function x when x < 0. -> -1. | _ -> 1.

let run_ralg f_obj f_grad x0 =
  let f_cb x = Some ( (f_obj x), (f_grad x) ) in
  ralg ralg_options f_cb x0

let test_abs() =
  let x0 = Float.Array.make 2 1000. in

  let f_obj x =
    let x0 = Float.Array.get x 0 in
    let x1 = Float.Array.get x 1 in
    ( abs_float ( x0-.3. ) ) +. 100.*.( abs_float( x0+.2.) ) +. 0.001*.( abs_float x1 ) in
  let f_grad x =
    let x0 = Float.Array.get x 0 in
    let x1 = Float.Array.get x 1 in
    let g0 = ( sign ( x0-.3. ) ) +. 100.*.( sign ( x0 +. 2. ) ) in
    let g1 = 0.001*.(sign x1) in
    let res = Float.Array.create 2 in
    Float.Array.set res 0 g0;
    Float.Array.set res 1 g1;
    res
  in
  let opt_obj, opt_x = run_ralg f_obj f_grad x0 in
  Printf.printf "OCaml side: optimal objective %f, optimal point is %f, %f\n" opt_obj (Float.Array.get opt_x 0) (Float.Array.get opt_x 1);
  if abs_float (opt_obj -. 5.) < 1.e-10 then
    Printf.printf "TEST OK\n"
  else
    Printf.printf "----------- TEST FAILED at %f ----------\n" opt_obj

let test_stress () =
  (* this is a high dimension test with a very quick callback and large dimendsions to test latecncy between OCaml stubs and direct C++ run *)
  let dims = 30 in
  let x0 = Float.Array.make dims 1000. in

  let f_obj x =
    snd @@ Float.Array.fold_left (fun (i,prev) xi -> i+.1., prev +. i*.(abs_float (xi -. i))) (1., 0.) x
  in
  let f_grad x =
    Float.Array.init dims (fun i ->
      let fi = 1. +. float i in
      let xi = Float.Array.get x i in
      fi *. (sign ( (xi -. fi) ) )
    )
  in
  let opt_obj, opt_x = run_ralg f_obj f_grad x0 in
  Printf.printf "STRESS test Objective %f\n" opt_obj;
  Float.Array.iteri (fun i x ->
    Printf.printf "solution x %d = %f\n" i x
  ) opt_x;
  ()


let () =
  let () = test_abs () in
  let () = test_stress () in
  ()
