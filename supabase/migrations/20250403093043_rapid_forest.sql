/*
  # Row Level Security Policies
  
  1. Changes
    - Add RLS policies for all tables
    - Set up proper access control
*/

-- Users policies
CREATE POLICY "Users can view all users"
  ON users
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update their own data"
  ON users
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Shifts schedule policies
CREATE POLICY "Anyone can read shifts schedule"
  ON shifts_schedule
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage shifts schedule"
  ON shifts_schedule
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND role = 'admin'
    )
  );

-- Shift swaps policies
CREATE POLICY "Users can create swap requests"
  ON shift_swaps
  FOR INSERT
  TO authenticated
  WITH CHECK (
    from_employee = (SELECT full_name FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Users can view their swap requests"
  ON shift_swaps
  FOR SELECT
  TO authenticated
  USING (
    from_employee = (SELECT full_name FROM users WHERE id = auth.uid()) OR
    to_employee = (SELECT full_name FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Users can update their swap requests"
  ON shift_swaps
  FOR UPDATE
  TO authenticated
  USING (
    (to_employee = (SELECT full_name FROM users WHERE id = auth.uid()) AND status = 'pending') OR
    (from_employee = (SELECT full_name FROM users WHERE id = auth.uid()) AND status = 'pending')
  )
  WITH CHECK (
    status IN ('accepted', 'rejected', 'cancelled')
  );

-- Notifications policies
CREATE POLICY "Users can view their notifications"
  ON notifications
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update their notifications"
  ON notifications
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());