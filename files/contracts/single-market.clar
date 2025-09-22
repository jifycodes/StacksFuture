;; BTC-USD Perpetuals Contract
;; Simple isolated margin perpetual futures

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-POSITION-EXISTS (err u102))
(define-constant ERR-NO-POSITION (err u103))
(define-constant ERR-INVALID-PARAMS (err u104))
(define-constant ERR-LIQUIDATION-FAILED (err u105))

(define-data-var contract-owner principal tx-sender)
(define-data-var btc-price uint u45000000000) ;; $45k with 6 decimals
(define-data-var maintenance-margin uint u50000) ;; 5%
(define-data-var max-leverage uint u10)

;; User balances in STX
(define-map balances principal uint)

;; User positions
(define-map positions principal {
  size: uint,
  is-long: bool,
  entry-price: uint,
  margin: uint,
  leverage: uint
})

;; Get user balance
(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? balances user))
)

;; Get position
(define-read-only (get-position (user principal))
  (map-get? positions user)
)

;; Calculate PnL
(define-read-only (get-pnl (user principal))
  (match (get-position user)
    pos (let ((size (get size pos))
              (entry (get entry-price pos))
              (current (var-get btc-price))
              (is-long (get is-long pos)))
          (if is-long
            (if (> current entry)
              (to-int (/ (* size (- current entry)) entry))
              (- (to-int (/ (* size (- entry current)) entry))))
            (if (> entry current)
              (to-int (/ (* size (- entry current)) entry))
              (- (to-int (/ (* size (- current entry)) entry))))))
    0))

;; Deposit STX
(define-public (deposit (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set balances tx-sender (+ (get-balance tx-sender) amount))
    (ok amount)))

;; Withdraw STX
(define-public (withdraw (amount uint))
  (let ((balance (get-balance tx-sender)))
    (asserts! (>= balance amount) ERR-INSUFFICIENT-FUNDS)
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (map-set balances tx-sender (- balance amount))
    (ok amount)))

;; Open position
(define-public (open-position (size uint) (is-long bool) (leverage uint))
  (let ((balance (get-balance tx-sender))
        (required-margin (/ size leverage))
        (price (var-get btc-price)))
    (asserts! (is-none (get-position tx-sender)) ERR-POSITION-EXISTS)
    (asserts! (and (> size u0) (<= leverage (var-get max-leverage))) ERR-INVALID-PARAMS)
    (asserts! (>= balance required-margin) ERR-INSUFFICIENT-FUNDS)
    
    (map-set balances tx-sender (- balance required-margin))
    (map-set positions tx-sender {
      size: size,
      is-long: is-long,
      entry-price: price,
      margin: required-margin,
      leverage: leverage
    })
    (ok true)))

;; Close position
(define-public (close-position)
  (match (get-position tx-sender)
    pos (let ((pnl (get-pnl tx-sender))
              (margin (get margin pos))
              (balance (get-balance tx-sender)))
          (map-delete positions tx-sender)
          (if (>= pnl 0)
            (map-set balances tx-sender (+ balance margin (to-uint pnl)))
            (if (>= margin (to-uint (- pnl)))
              (map-set balances tx-sender (+ balance (- margin (to-uint (- pnl)))))
              (map-set balances tx-sender balance)))
          (ok pnl))
    ERR-NO-POSITION))

;; Liquidate position
(define-public (liquidate (user principal))
  (match (get-position user)
    pos (let ((pnl (get-pnl user))
              (margin (get margin pos))
              (liquidation-threshold (/ (* margin (var-get maintenance-margin)) u1000000)))
          (asserts! (< (+ margin (if (>= pnl 0) (to-uint pnl) (- (to-uint (- pnl))))) liquidation-threshold) ERR-LIQUIDATION-FAILED)
          (map-delete positions user)
          (map-set balances user u0) ;; Position liquidated
          (map-set balances tx-sender (+ (get-balance tx-sender) (/ margin u40))) ;; 2.5% reward
          (ok true))
    ERR-NO-POSITION))

;; Admin: Update BTC price
(define-public (update-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set btc-price new-price)
    (ok new-price)))