(*
 * Copyright (c) 2013-2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Lwt_unix IO module. *)

open Git

module type S = sig

  (** {1 Unix implementation}

      The Unix implementation fix the choice of [Git.Inflate.S] and
      [Git.SHA.DIGEST]. By default, it uses [camlzip] and
      [nocrypto].

      It also uses [Lwt_unix] and [Lwt_io] for the IO functions. *)

  (** {1 Synchronisation} *)

  module Sync: sig
    module IO: Sync.IO
    module Result: (module type of Sync.Result
                     with type fetch = Sync.Result.fetch
                      and type push  = Sync.Result.push)
    module Make (S: Store.S): Sync.S with type t = S.t
  end

  (** {1 Filesystem} *)

  (** Implementation of the on-disk Git protocol using [Lwt_unix]. *)
  module FS: sig
    module IO: FS.IO
    include FS.S
  end

  module Memory: Store.S
  (** In-memory store. *)

  (** {1 Git objects} *)

  module SHA_IO: SHA.IO
  module Value_IO: Value.IO
  module Pack_IO: Pack.IO
  module Index_IO: Index.IO

end

include S

module Make (D: Git.SHA.DIGEST) (I: Git.Inflate.S): S
(** Parametrize the Git implementation with different inflate and hash
    algorithms. {b Note:} this might cause your implementation to not
    be compatible with Git anynore! *)

module Inflate: Inflate.S
(** Implementation of the inflate signature using [camlzip]. *)

module Digest: Git.SHA.DIGEST
(** Implementation of the digest signature using [ocaml-nocrypto]. *)
