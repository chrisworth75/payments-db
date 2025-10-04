-- Sample data for payments database

-- Sample payment_fee_link
INSERT INTO payment_fee_link (id, date_created, date_updated, payment_reference, org_id, enterprise_service_name, ccd_case_number, case_reference, service_request_callback_url)
VALUES
(1, NOW(), NOW(), 'PAY-REF-001', 'ORG001', 'DIVORCE', '1234567890123456', 'DIV-001', 'http://localhost:3000/callback'),
(2, NOW(), NOW(), 'PAY-REF-002', 'ORG001', 'PROBATE', '2345678901234567', 'PRB-001', 'http://localhost:3000/callback');

-- Sample fees
INSERT INTO fee (id, code, version, payment_link_id, calculated_amount, volume, ccd_case_number, reference, net_amount, fee_amount, amount_due, date_created, date_updated)
VALUES
(1, 'FEE0001', 1, 1, 550.00, 1, '1234567890123456', 'FEE-REF-001', 550.00, 550.00, 550.00, NOW(), NOW()),
(2, 'FEE0002', 1, 2, 273.00, 1, '2345678901234567', 'FEE-REF-002', 273.00, 273.00, 273.00, NOW(), NOW());

-- Sample payments
INSERT INTO payment (id, amount, case_reference, ccd_case_number, currency, date_created, date_updated, description, service_type, site_id, payment_channel, payment_method, payment_provider, payment_status, payment_link_id, reference)
VALUES
(1, 550.00, 'DIV-001', '1234567890123456', 'GBP', NOW(), NOW(), 'Divorce application fee', 'DIVORCE', 'SITE001', 'online', 'card', 'gov_pay', 'Success', 1, 'RC-1234-5678-9012-3456'),
(2, 273.00, 'PRB-001', '2345678901234567', 'GBP', NOW(), NOW(), 'Probate application fee', 'PROBATE', 'SITE001', 'online', 'card', 'gov_pay', 'Success', 2, 'RC-2345-6789-0123-4567');

-- Sample fee_pay_apportion
INSERT INTO fee_pay_apportion (id, payment_id, fee_id, payment_link_id, fee_amount, payment_amount, ccd_case_number, apportion_type, date_created, date_updated, apportion_amount)
VALUES
(1, 1, 1, 1, 550.00, 550.00, '1234567890123456', 'AUTO', NOW(), NOW(), 550.00),
(2, 2, 2, 2, 273.00, 273.00, '2345678901234567', 'AUTO', NOW(), NOW(), 273.00);

-- Sample status_history
INSERT INTO status_history (id, date_created, date_updated, external_status, status, payment_id)
VALUES
(1, NOW(), NOW(), 'created', 'Initiated', 1),
(2, NOW(), NOW(), 'success', 'Success', 1),
(3, NOW(), NOW(), 'created', 'Initiated', 2),
(4, NOW(), NOW(), 'success', 'Success', 2);

-- Sample payment_audit_history
INSERT INTO payment_audit_history (id, ccd_case_no, audit_type, audit_payload, audit_description, date_created, date_updated)
VALUES
(1, '1234567890123456', 'PAYMENT_CREATED', '{"reference": "RC-1234-5678-9012-3456", "amount": 550.00}', 'Payment created for divorce case', NOW(), NOW()),
(2, '2345678901234567', 'PAYMENT_CREATED', '{"reference": "RC-2345-6789-0123-4567", "amount": 273.00}', 'Payment created for probate case', NOW(), NOW());
