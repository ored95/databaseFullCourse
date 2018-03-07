using System;
using System.Data;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text;

[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedType(Microsoft.SqlServer.Server.Format.Native, IsByteOrdered = true)]
public struct Vector : INullable
{
    #region Private fields
    
    private Int32 _x;
    private Int32 _y;
    private bool _isNull;

    #endregion

    #region Constructor

    public Vector(Int32 x, Int32 y)
    {
        this._x = x;
        this._y = y;
        this._isNull = false;
    }

    public Vector(bool isNull)
    {
        this._x = this._y = 0;
        this._isNull = isNull;
    }

    #endregion

    #region Public Get-Set fields

    public Int32 X
    {
        get { return this._x; }
        set { _x = (Int32)value; }
    }  
  
    public Int32 Y  
    {  
        get { return this._y; }
        set { _y = (Int32)value; }
    }

    public bool IsNull
    {
        get { return _isNull; }
    }
    
    public static Vector Null
    {
        get { return new Vector(true); }
    }
    #endregion

    #region Properties
    
    /// <summary>
    /// Identifies vector is Zero.
    /// </summary>
    /// <returns></returns>
    public bool IsZero()
    {
        return this.X == 0 && this.Y == 0;
    }

    /// <summary>
    /// provide string representation for UDT. (use StringBuilder)
    /// </summary>
    /// <returns>Vector representation</returns>
    public override string ToString()
    {
        // Since InvokeIfReceiverIsNull defaults to 'true'  
        // this test is unneccesary if Vector is only being called  
        // from SQL.
        if (this.IsNull)
            return "Vector Null";
        else
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("Vector ({0}, {1})", _x, _y);
            return sb.ToString();
        }
    }

    /// <summary>
    /// Parse input string to the Vector structure
    /// </summary>
    /// <param name="source">Parsed string</param>
    /// <returns></returns>
    [SqlMethod(OnNullCall = false)]
    public static Vector Parse(SqlString source)
    {
        // With OnNullCall=false, this check is unnecessary if   
        // Vector only called from SQL.
        if (source.IsNull)
            return new Vector(true);

        // Parse input string (source) to separate out Vectors
        string[] value = source.Value.Split(",".ToCharArray());
        if (value.Length != 2)
            throw new ArgumentOutOfRangeException("Length is out of range, must be equal to 2!");

        try
        {
            return new Vector(Int32.Parse(value[0]), Int32.Parse(value[1]));
        }
        catch (Exception e)
        {
            throw e;
        }
    }

    [SqlMethod(OnNullCall = false)]
    public Double Length()
    {
        if (this.IsNull)
            throw new InvalidOperationException();
        return Math.Sqrt(_x * _x + _y * _y);
    }

    [SqlMethod(OnNullCall = false)]
    public Vector Add(Vector v)
    {
        if (this.IsNull || v.IsNull)
            throw new ArgumentNullException();
        return new Vector(this.X + v.X, this.Y + v.Y);
    }

    [SqlMethod(OnNullCall = false)]
    public Int32 Dot(Vector a, Vector b)
    {
        if (a.IsNull || b.IsNull)
            throw new ArgumentNullException();
        return a.X * b.X + a.Y * b.Y;
    }

    [SqlMethod(OnNullCall = false)]
    public Vector Scale(Int32 value)
    {
        if (this.IsNull)
            throw new ArgumentNullException();
        return new Vector(this.X * value, this.Y * value);
    }

    #endregion
}