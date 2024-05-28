use sqlx::SqliteConnection;
use tari_common_types::tari_address::TariAddress;

use crate::{
    db_types::{NewPayment, Payment, TransferStatus},
    traits::PaymentGatewayError,
};

pub async fn idempotent_insert(
    transfer: NewPayment,
    conn: &mut SqliteConnection,
) -> Result<String, PaymentGatewayError> {
    let txid = transfer.txid.clone();
    let address = transfer.sender.as_address().to_hex();
    match sqlx::query!(
        r#"
            INSERT INTO payments (txid, sender, amount, memo) VALUES ($1, $2, $3, $4)
            RETURNING txid;
        "#,
        transfer.txid,
        address,
        transfer.amount,
        transfer.memo,
    )
    .fetch_one(conn)
    .await
    {
        Ok(row) => Ok(row.txid),
        Err(sqlx::Error::Database(e)) if e.is_unique_violation() => {
            Err(PaymentGatewayError::PaymentAlreadyExists(txid))
        },
        Err(e) => Err(PaymentGatewayError::from(e)),
    }
}

pub async fn update_status(
    txid: &str,
    status: TransferStatus,
    conn: &mut SqliteConnection,
) -> Result<(), PaymentGatewayError> {
    let status = status.to_string();
    let _ = sqlx::query!("UPDATE payments SET status = $1 WHERE txid = $2", status, txid).execute(conn).await?;
    Ok(())
}

pub async fn fetch_payment(txid: &str, conn: &mut SqliteConnection) -> Result<Option<Payment>, PaymentGatewayError> {
    let payment = sqlx::query_as(r#"SELECT * FROM payments WHERE txid = ?"#).bind(txid).fetch_optional(conn).await?;
    Ok(payment)
}

pub async fn fetch_payments_for_address(
    address: &TariAddress,
    conn: &mut SqliteConnection,
) -> Result<Vec<Payment>, sqlx::Error> {
    let payments =
        sqlx::query_as(r#"SELECT * FROM payments WHERE sender = ?"#).bind(address.to_hex()).fetch_all(conn).await?;
    Ok(payments)
}