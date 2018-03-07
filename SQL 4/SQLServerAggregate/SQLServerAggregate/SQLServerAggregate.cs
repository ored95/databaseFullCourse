using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.IO;

namespace SqlUserDefinedAggregateAttribute
{
    /// <summary>
    /// Calculates the geometric mean of numerical values
    /// </summary>
    [System.Serializable]
    [Microsoft.SqlServer.Server.SqlUserDefinedAggregate(
        Microsoft.SqlServer.Server.Format.Native,
        IsInvariantToDuplicates = false,    // receiving the same value again
                    // changes the result
        IsInvariantToNulls = false,         // receiving a NULL value changes the result
        IsInvariantToOrder = true,          // the order of the values doesn't affect the result
        IsNullIfEmpty = true,               // if no values are given the result is null
        Name = "GeometricProduct")]         // name of the aggregate
    public struct GeometricProduct
    {
        /// <summary>
        /// Used to store the product
        /// </summary>
        public System.Data.SqlTypes.SqlDouble Product { get; private set; }

        /// <summary>
        /// Number of values in the set
        /// </summary>
        public double ValueCount { get; private set; }

        /// <summary>
        /// Initializes a new Product for a group
        /// </summary>
        public void Init()
        {
            this.Product = System.Data.SqlTypes.SqlDouble.Null;
            this.ValueCount = 0;
        }

        // <summary>
        /// Calculates the product of the previous values and the value received
        /// </summary>
        /// <param name="number">Value to include</param>
        public void Accumulate(System.Data.SqlTypes.SqlDouble number)
        {
            if (this.ValueCount == 0)
            {
                // if this is the first value received
                this.Product = number;
            }
            else if (this.Product.IsNull)
            {
                //if the calculated value is null, stay that way
            }
            else if (number.IsNull)
            {
                //if the value is null the result is null
                this.Product = System.Data.SqlTypes.SqlDouble.Null;
            }
            else
            {
                //multiply the values
                this.Product = System.Data.SqlTypes.SqlDouble.Multiply(this.Product, number);
            }
            this.ValueCount++;
        }

        /// <summary>
        /// Merges this group to another group instantiated for the calculation
        /// </summary>
        /// <param name="group"></param>
        public void Merge(GeometricProduct group)
        {
            //Count the product only if the other group has values
            if (group.ValueCount > 0)
            {
                this.Product = System.Data.SqlTypes.SqlDouble.Multiply(this.Product, group.Product);
            }
            this.ValueCount += group.ValueCount;
        }

        /// <summary>
        /// Ends the calculation for this group and returns the result
        /// </summary>
        /// <returns></returns>
        public System.Data.SqlTypes.SqlDouble Terminate()
        {
            return this.ValueCount > 0 && !this.Product.IsNull
               ? System.Math.Pow(this.Product.Value, 1 / this.ValueCount)
               : System.Data.SqlTypes.SqlDouble.Null;
        }
    }

    /// <summary>
    /// Concatenates the strings with a given delimiter
    /// </summary>
    [System.Serializable]
    [Microsoft.SqlServer.Server.SqlUserDefinedAggregate(
       Microsoft.SqlServer.Server.Format.UserDefined,
       IsInvariantToDuplicates = false, // Receiving the same value again 
				     // changes the result
       IsInvariantToNulls = false,      // Receiving a NULL value changes the result
       IsInvariantToOrder = false,      // The order of the values affects the result
       IsNullIfEmpty = true,            // If no values are given the result is null
       MaxByteSize = 8000,                // Maximum size of the aggregate instance. 
                                        // -1 represents a value larger than 8000 bytes,
                                        // up to 2 gigabytes
       Name = "Concat"             // Name of the aggregate
    )]
    public struct Concat : IBinarySerialize
    {
        /// <summary>
        /// Used to store the concatenated string
        /// </summary>
        public StringBuilder Result { get; private set; }

        /// <summary>
        /// Used to save the delimiter
        /// </summary>
        public SqlString Delimiter { get; private set; }

        /// <summary>
        /// Used to inform if string has a value
        /// </summary>
        public bool HasValue { get; private set; }

        /// <summary>
        /// Used to inform if the string is NULL
        /// </summary>
        public bool IsNull { get; private set; }

        /// <summary>
        /// Is the concatenation resulting a NULL if some of the values contain NULL
        /// </summary>
        public bool NullYieldsToNull { get; private set; }

        /// <summary>
        /// [NEED #1] Initialize a new Concat for a group
        /// </summary>
        public void Init()
        {
            this.Result = new StringBuilder("");
            this.HasValue = false;
            this.IsNull = false;
        }

        /// <summary>
        /// [NEED #2] Insert a new string into the existing already concatenated string
        /// </summary>
        /// <param name="stringAdd">The new string</param>
        /// <param name="delimiter">Delimiter</param>
        /// <param name="nullYieldsToNull">Is the concatenation resulting a NULL 
        ///                                if some of the values contain NULL</param>
        public void Accumulate(SqlString stringAdd, SqlString delimiter, SqlBoolean nullYieldsToNull)
        {
            if (!this.HasValue)
            {
                // if this is the first value received
                if (nullYieldsToNull && stringAdd.IsNull)
                {
                    this.IsNull = true;
                }
                else if (stringAdd.IsNull) { }
                else { this.Result.Append(stringAdd); }

                this.Delimiter = delimiter;
                this.NullYieldsToNull = nullYieldsToNull.Value;
            }
            else if (this.IsNull && nullYieldsToNull.Value)
            { } // if the concatenated value is null, stayed that way
            else if (stringAdd.IsNull && nullYieldsToNull.Value)
            {
                // if stringAdd is null and flag nullYieldsToNull is true
                this.IsNull = true;
            }
            else
            {
                // concatenate values in the only case the stringAdd is not null
                if (!stringAdd.IsNull)
                    this.Result.AppendFormat("{0}{1}", delimiter.Value, stringAdd.Value);
            }

            // the flag HasValue is true, if a value has already been set or the stringAdd is not null
            this.HasValue = this.HasValue || !(stringAdd.IsNull && !nullYieldsToNull.Value);
        }

        /// <summary>
        /// [NEED #3] Merges the current group to another group instantiated for the concatenation
        /// </summary>
        /// <param name="group">The group to merge</param>
        public void Merge(Concat group)
        {
            // Merge that group in only case of HasValue
            if (group.HasValue)
            {
                this.Accumulate(group.Result.ToString(), this.Delimiter, this.NullYieldsToNull);
            }
        }

        /// <summary>
        /// [NEED #4] Ends the operation and returns the value
        /// </summary>
        public SqlString Terminate()
        {
            return this.IsNull ? SqlString.Null : this.Result.ToString();
        }

        #region IBinarySerialize
        
        /// <summary>
        /// Reads the values from stream
        /// </summary>
        /// <param name="reader">The BinaryReader stream</param>
        public void Read(BinaryReader reader)
        {
            this.Result = new StringBuilder(reader.ReadString());
            this.Delimiter = new SqlString(reader.ReadString());
            this.HasValue = reader.ReadBoolean();
            this.IsNull = reader.ReadBoolean();
            this.NullYieldsToNull = reader.ReadBoolean();
        }

        /// <summary>
        /// Writes the values to the stream in order to be stored
        /// </summary>
        /// <param name="writer">The BinaryWriter stream</param>
        public void Write(BinaryWriter writer)
        {
            writer.Write(this.Result.ToString());
            writer.Write(this.Delimiter.ToString());
            writer.Write(this.HasValue.ToString());
            writer.Write(this.IsNull.ToString());
            writer.Write(this.NullYieldsToNull.ToString());
        }

        #endregion
    }
}
