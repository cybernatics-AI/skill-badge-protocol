;; Simple Skill Badge Protocol Smart Contract
;; A streamlined system for minting skill-based NFT badges

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u1000))
(define-constant ERR-ALREADY-EXISTS (err u1001))
(define-constant ERR-NOT-FOUND (err u1002))
(define-constant ERR-INVALID-AMOUNT (err u1003))
(define-constant ERR-ALREADY-ENDORSED (err u1004))
(define-constant ERR-CANNOT-ENDORSE-SELF (err u1005))
(define-constant ERR-INVALID-SKILL (err u1006))
(define-constant ERR-INVALID-LEVEL (err u1007))
(define-constant ERR-ALREADY-COMPLETED (err u1008))

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-STAKE-AMOUNT u100000) ;; 0.1 STX in microSTX

;; Data structures
(define-map skills
    { skill-id: uint }
    { name: (string-ascii 64), category: (string-ascii 32), active: bool }
)

(define-map badges
    { badge-id: uint }
    { owner: principal, skill-id: uint, level: uint, verified: bool }
)

(define-map endorsements
    { endorser: principal, endorsee: principal, skill-id: uint }
    { stake-amount: uint, verified: bool }
)

(define-map user-reputation
    { user: principal }
    { total-score: uint, badges-earned: uint }
)

;; NFT definition
(define-non-fungible-token skill-badge uint)

;; Data variables
(define-data-var next-skill-id uint u1)
(define-data-var next-badge-id uint u1)

;; Private functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT-OWNER)
)

;; Public functions

;; Add new skill
(define-public (add-skill (name (string-ascii 64)) (category (string-ascii 32)))
    (let ((skill-id (var-get next-skill-id)))
        (asserts! (is-contract-owner) ERR-UNAUTHORIZED)
        (map-set skills { skill-id: skill-id } { name: name, category: category, active: true })
        (var-set next-skill-id (+ skill-id u1))
        (ok skill-id)
    )
)

;; Endorse a skill
(define-public (endorse-skill (endorsee principal) (skill-id uint) (stake-amount uint))
    (let ((endorsement-key { endorser: tx-sender, endorsee: endorsee, skill-id: skill-id }))
        (asserts! (not (is-eq tx-sender endorsee)) ERR-CANNOT-ENDORSE-SELF)
        (asserts! (is-some (map-get? skills { skill-id: skill-id })) ERR-INVALID-SKILL)
        (asserts! (>= stake-amount MIN-STAKE-AMOUNT) ERR-INVALID-AMOUNT)
        (asserts! (is-none (map-get? endorsements endorsement-key)) ERR-ALREADY-ENDORSED)
        
        (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
        (map-set endorsements endorsement-key { stake-amount: stake-amount, verified: false })
        (ok true)
    )
)

;; Verify endorsement and mint badge
(define-public (verify-endorsement (endorsee principal) (skill-id uint) (level uint))
    (let ((badge-id (var-get next-badge-id)))
        (asserts! (is-contract-owner) ERR-UNAUTHORIZED)
        (asserts! (and (>= level u1) (<= level u5)) ERR-INVALID-LEVEL)
        (asserts! (is-some (map-get? skills { skill-id: skill-id })) ERR-INVALID-SKILL)
        
        (try! (nft-mint? skill-badge badge-id endorsee))
        (map-set badges { badge-id: badge-id } { 
            owner: endorsee, 
            skill-id: skill-id, 
            level: level, 
            verified: true 
        })
        
        ;; Update reputation
        (let ((current-rep (default-to { total-score: u0, badges-earned: u0 } 
                                      (map-get? user-reputation { user: endorsee }))))
            (map-set user-reputation { user: endorsee } {
                total-score: (+ (get total-score current-rep) (* level u10)),
                badges-earned: (+ (get badges-earned current-rep) u1)
            })
        )
        
        (var-set next-badge-id (+ badge-id u1))
        (ok badge-id)
    )
)

;; Direct badge mint (for challenges or other verification methods)
(define-public (mint-badge (recipient principal) (skill-id uint) (level uint))
    (let ((badge-id (var-get next-badge-id)))
        (asserts! (is-contract-owner) ERR-UNAUTHORIZED)
        (asserts! (and (>= level u1) (<= level u5)) ERR-INVALID-LEVEL)
        (asserts! (is-some (map-get? skills { skill-id: skill-id })) ERR-INVALID-SKILL)
        
        (try! (nft-mint? skill-badge badge-id recipient))
        (map-set badges { badge-id: badge-id } { 
            owner: recipient, 
            skill-id: skill-id, 
            level: level, 
            verified: true 
        })
        
        ;; Update reputation
        (let ((current-rep (default-to { total-score: u0, badges-earned: u0 } 
                                      (map-get? user-reputation { user: recipient }))))
            (map-set user-reputation { user: recipient } {
                total-score: (+ (get total-score current-rep) (* level u15)),
                badges-earned: (+ (get badges-earned current-rep) u1)
            })
        )
        
        (var-set next-badge-id (+ badge-id u1))
        (ok badge-id)
    )
)

;; Withdraw staked funds (for contract owner)
(define-public (withdraw-funds (amount uint))
    (begin
        (asserts! (is-contract-owner) ERR-UNAUTHORIZED)
        (try! (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER)))
        (ok true)
    )
)

;; Read-only functions

(define-read-only (get-skill (skill-id uint))
    (map-get? skills { skill-id: skill-id })
)

(define-read-only (get-badge (badge-id uint))
    (map-get? badges { badge-id: badge-id })
)

(define-read-only (get-user-reputation (user principal))
    (default-to { total-score: u0, badges-earned: u0 }
                (map-get? user-reputation { user: user }))
)

(define-read-only (get-endorsement (endorser principal) (endorsee principal) (skill-id uint))
    (map-get? endorsements { endorser: endorser, endorsee: endorsee, skill-id: skill-id })
)

(define-read-only (get-badge-owner (badge-id uint))
    (nft-get-owner? skill-badge badge-id)
)

(define-read-only (get-next-ids)
    { next-skill-id: (var-get next-skill-id), next-badge-id: (var-get next-badge-id) }
)