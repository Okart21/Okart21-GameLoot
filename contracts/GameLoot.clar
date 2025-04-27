;; GameLoot - A cross-game NFT platform for in-game items
;; This contract allows games to register and players to use NFT items across multiple games

(define-non-fungible-token game-item uint)

;; Data storage
(define-map item-details uint {name: (string-ascii 64), description: (string-ascii 256), image-uri: (string-utf8 256)})
(define-map item-attributes uint (list 20 {trait: (string-ascii 32), value: (string-ascii 64)}))
(define-map game-registry principal {name: (string-ascii 64), active: bool})
(define-map game-item-compatibility {game-id: principal, item-id: uint} {compatible: bool, power-level: uint})
(define-map item-ownership uint principal)

;; Error codes
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_GAME_NOT_REGISTERED (err u101))
(define-constant ERR_ITEM_NOT_FOUND (err u102))
(define-constant ERR_ALREADY_REGISTERED (err u103))
(define-constant ERR_INVALID_PARAMS (err u104))
(define-constant ERR_NOT_OWNER (err u105))

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Admin functions
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (ok (var-set contract-owner new-owner))))

;; Game registration
(define-public (register-game (game-name (string-ascii 64)))
  (let ((game-exists (default-to {name: "", active: false} (map-get? game-registry tx-sender))))
    (asserts! (not (get active game-exists)) ERR_ALREADY_REGISTERED)
    (ok (map-set game-registry tx-sender {name: game-name, active: true}))))

(define-public (deactivate-game)
  (let ((game-exists (default-to {name: "", active: false} (map-get? game-registry tx-sender))))
    (asserts! (get active game-exists) ERR_GAME_NOT_REGISTERED)
    (ok (map-set game-registry tx-sender 
      {name: (get name game-exists), active: false}))))

;; NFT functions
(define-public (mint-item 
    (recipient principal) 
    (item-id uint) 
    (name (string-ascii 64)) 
    (description (string-ascii 256)) 
    (image-uri (string-utf8 256)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get contract-owner)) 
                 (is-some (map-get? game-registry tx-sender))) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (nft-get-owner? game-item item-id)) ERR_ALREADY_REGISTERED)
    
    (try! (nft-mint? game-item item-id recipient))
    (map-set item-details item-id {name: name, description: description, image-uri: image-uri})
    (map-set item-ownership item-id recipient)
    (ok item-id)))

(define-public (transfer-item (item-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? game-item item-id) ERR_ITEM_NOT_FOUND)) ERR_NOT_OWNER)
    (try! (nft-transfer? game-item item-id tx-sender recipient))
    (map-set item-ownership item-id recipient)
    (ok true)))

;; Game compatibility functions
(define-public (set-item-compatibility (item-id uint) (power-level uint) (compatible bool))
  (begin
    (asserts! (is-some (map-get? game-registry tx-sender)) ERR_GAME_NOT_REGISTERED)
    (asserts! (is-some (nft-get-owner? game-item item-id)) ERR_ITEM_NOT_FOUND)
    (ok (map-set game-item-compatibility {game-id: tx-sender, item-id: item-id} 
                {compatible: compatible, power-level: power-level}))))

;; Item attribute functions
(define-public (set-item-attributes (item-id uint) (attributes (list 20 {trait: (string-ascii 32), value: (string-ascii 64)})))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (nft-get-owner? game-item item-id)) ERR_ITEM_NOT_FOUND)
    (ok (map-set item-attributes item-id attributes))))

;; Read-only functions
(define-read-only (get-item-details (item-id uint))
  (map-get? item-details item-id))

(define-read-only (get-item-attributes (item-id uint))
  (map-get? item-attributes item-id))

(define-read-only (get-item-compatibility (game-id principal) (item-id uint))
  (map-get? game-item-compatibility {game-id: game-id, item-id: item-id}))

(define-read-only (get-game-info (game-id principal))
  (map-get? game-registry game-id))

(define-read-only (get-item-owner (item-id uint))
  (nft-get-owner? game-item item-id))

(define-read-only (is-game-active (game-id principal))
  (match (map-get? game-registry game-id)
    game-data (get active game-data)
    false))